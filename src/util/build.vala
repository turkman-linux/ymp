private build_target[] bts;
public class build_target {
    public string name;
    public string suffix;
    public string arch;
    public builder builder;
    public signal string create_source_archive();
    public signal bool create_files_info();
    public signal bool create_metadata_info();
    public signal void create_data_file();
    public signal string create_binary_package();
}

public void add_build_target(build_target bt) {
    if (bts == null) {
        bts = {};
    }
    bts += bt;
}

private bool builder_init = false;
public class builder {

    public builder() {
        if(!builder_init){
            builder_ctx_init();
            builder_init = true;
        }
        ymp_build = new ympbuild();
        string target = get_value("build:target");
        if (target == "") {
            target = "ymp";
        }
        foreach(build_target b in bts) {
            if (b.name == target) {
                build_target = b;
                build_target.builder = this;
                break;
            }
        }
        if (build_target == null) {
            error_add(_("Failed to detect build target: %s").printf(target));
            error(1);
        }
    }

    public ympbuild ymp_build;
    public string output;
    public build_target build_target;
    public string output_package_name;
    public int build_single(string path) {
        save_env();
        clear_env();
        setenv("PATH","/sbin:/bin:/usr/sbin:/usr/bin", 1);
        bool unsafe = get_bool("unsafe");
        string srcpath = srealpath(path);
        string srcpkg = "";
        string binpkg = "";
        output = get_value("output");
        if (output == "") {
            output = srealpath(srcpath);
        } else {
            output = srealpath(output);
        }

        if (startswith(path, "git@") || endswith(path, ".git")) {
            set_bool("unsafe", true);
            srcpath = get_build_dir() + "/" + sbasename(path);
            if (isdir(srcpath)) {
                remove_all(srcpath);
            }
            if(get_value("output") == ""){
                output=pwd();
            }
            if (run("git clone '" + path + "' " + srcpath) != 0) {
                error_add(_("Failed to fetch git package."));
                restore_env();
                return 2;
            }
        } else if (startswith(path, "http://") || startswith(path, "https://")) {
            set_bool("unsafe", true);
            string file = get_build_dir() + "/.cache/" + sbasename(path);
            create_dir(file);
            string farg = file + "/" + sbasename(path);
            if (!isfile(farg)) {
                fetch(path, farg);
            }
            srcpath = farg;
        }
        if (!isdir(output)) {
            create_dir(output);
        }
        if (isfile(srcpath)) {
            string srcdir = get_build_dir() + "/" + calculate_md5sum(srcpath);
            create_dir(srcdir);
            var tar = new archive();
            tar.load(srcpath);
            tar.set_target(srcdir);
            tar.extract_all();
            srcpath = srcdir;
            if (!isfile(srcpath + "/ympbuild")) {
                error_add(_("Package is invalid: %s").printf(srcpath));
                set_bool("unsafe", unsafe);
                restore_env();
                return 2;
            }
        }
        if(!isfile(srcpath+"/ympbuild")){
            if(isfile(srcpath+"/PKGBUILD")){
                writefile(srcpath+"/ympbuild", 
                    get_pkgbuild_header().replace("@PKGBUILD@",srcpath+"/PKGBUILD")
                    + "\n# Uses PKGBUILD:" + calculate_md5sum(srcpath+"/PKGBUILD")
                );
            }
        }
        if (!isfile(srcpath + "/ympbuild")) {
            set_bool("unsafe", unsafe);
            restore_env();
            return 0;
        }
        if (!set_build_target(srcpath)) {
            error_add(_("Failed to set build target: %s").printf(srcpath));
            set_bool("unsafe", unsafe);
            restore_env();
            return 1;
        }

        // Set build target again (emerge change build target)
        ymp_build.set_ympbuild_srcpath(srcpath);
        string build_path = srealpath(get_build_dir() + "/" + calculate_md5sum(srcpath + "/ympbuild"));
        ymp_build.set_ympbuild_buildpath(build_path);

        info("Check build dependencies");
        if (!check_build_dependencies({srcpath})) {
            set_bool("unsafe", unsafe);
            restore_env();
            return 1;
        }
        info("Fetch sources");
        if (!fetch_package_sources()) {
            set_bool("unsafe", unsafe);
            restore_env();
            return 2;
        }
        if (!get_bool("no-source")) {
            info("Create source package");
            print(colorize(_("Create source package from :"), yellow) + ymp_build.ympbuild_srcpath);
            srcpkg = build_target.create_source_archive();
            if (srcpkg == "") {
                set_bool("unsafe", unsafe);
                restore_env();
                return 1;
            }
            if (srcpkg != "ignore") {
                string target = output + "/" + output_package_name + "_source.ymp";
                move_file(srcpkg, target);
            }
        }
        if (!get_bool("no-binary")) {
            if (!build_target.create_metadata_info()) {
                error_add(_("Failed to create metadata: %s").printf(srcpath));
                set_bool("unsafe", unsafe);
                restore_env();
                return 1;
            }
            info("Create binary package");
            if (!extract_package_sources()) {
                set_bool("unsafe", unsafe);
                restore_env();
                return 3;
            }
            if (!build_package()) {
                set_bool("unsafe", unsafe);
                restore_env();
                return 1;
            }
            print(colorize(_("Create binary package from: %s"), yellow).printf(build_path));
            binpkg = build_target.create_binary_package();
            if (binpkg == "") {
                set_bool("unsafe", unsafe);
                restore_env();
                return 1;
            }

            string target = output + "/" + output_package_name + "_" + build_target.arch + "." + build_target.suffix;
            move_file(binpkg, target);
        }
        set_bool("unsafe", unsafe);
        restore_env();
        return 0;
    }

    public bool check_build_dependencies(string[] args) {
        if (get_bool("ignore-dependency")) {
            warning(_("Dependency check disabled"));
            return true;
        }
        save_env();
        clear_env();
        setenv("PATH","/sbin:/bin:/usr/sbin:/usr/bin", 1);

        string metadata = ymp_build.get_ympbuild_metadata();
        var yaml = new yamlfile();
        yaml.data = metadata;
        yaml.data = yaml.get("ymp.source");
        var deps = new array();
        deps.adds(yaml.get_array(yaml.data, "makedepends"));
        deps.adds(yaml.get_array(yaml.data, "depends"));
        string name = yaml.get_value(yaml.data, "name");
        string[] use_flags = ssplit(get_value("use"), " ");
        string package_use = get_config("package.use", name);
        if (package_use.length > 0) {
            use_flags = ssplit(package_use, " ");
        }
        if ("all" in use_flags) {
            use_flags = yaml.get_array(yaml.data, "use-flags");
        }
        foreach(string flag in use_flags) {
            deps.adds(yaml.get_array(yaml.data, flag + "-depends"));
        }
        string[] pkgs = resolve_dependencies(deps.get());
        string[] need_install = {};
        foreach(string pkg in pkgs) {
            info(join(" ", pkgs));
            if (pkg in args || pkg == name) {
                continue;
            } else if (is_installed_package(pkg)) {
                continue;
            } else {
                need_install += pkg;
            }
        }
        if (need_install.length > 0) {
            if (get_bool("install")) {
                if(install_main(need_install) != 0){
                    error_add(_("Packages build canceled."));
                }
            } else {
                error_add(_("Packages is not installed: %s").printf(join(" ", need_install)));
            }
        }
        restore_env();
        return (!has_error());
    }

    public bool set_build_target(string src_path) {
        ymp_build.set_ympbuild_srcpath(src_path);
        string build_path = srealpath(get_build_dir() + "/" + calculate_md5sum(ymp_build.ympbuild_srcpath + "/ympbuild"));
        remove_all(build_path);
        ymp_build.set_ympbuild_buildpath(build_path);
        if (isdir(build_path)) {
            remove_all(build_path);
        }
        if (!ymp_build.ympbuild_check()) {
            error_add(_("ympbuild file is invalid!"));
            return false;
        }
        return true;
    }

    public bool fetch_package_sources() {
        int i = 0;
        if (no_src) {
            return true;
        }
        string[] sums = ymp_build.get_ympbuild_array("sha256sums");
        string algo = "sha256sum";
        if(sums.length == 0){
            warning(_("Ympbuild uses md5sums. Please replace with sha256sums."));
            sums = ymp_build.get_ympbuild_array("md5sums");
            algo = "md5sum";
        }
        foreach(string src in ymp_build.get_ympbuild_array("source")) {
            if (src == "" || sums[i] == "") {
                continue;
            }
            string name = sbasename(src);
            if ("::" in src){
                name = ssplit(src,"::")[0];
                src = ssplit(src,"::")[1];
            }
            string srcfile = ymp_build.ympbuild_buildpath + "/" + name;
            string ymp_source_cache = get_build_dir() + "/.cache/" + ymp_build.get_ympbuild_value("name") + "/";
            create_dir(ymp_source_cache);
            print(ymp_build.ympbuild_srcpath + "/" + name);
            print(src);
            if (isfile(srcfile)) {
                info(_("Source file already exists."));
            } else if (isfile(ymp_source_cache + "/" + name)) {
                info(_("Source file import from cache."));
                copy_file(ymp_source_cache + "/" + name, srcfile);
            } else if (isfile(ymp_build.ympbuild_srcpath + "/" + src)) {
                info(_("Source file copy from package."));
                copy_file(ymp_build.ympbuild_srcpath + "/" + src, srcfile);
            } else if (isfile(ymp_build.ympbuild_srcpath + "/" + name)) {
                info(_("Source file copy from package."));
                copy_file(ymp_build.ympbuild_srcpath + "/" + name, srcfile);
            } else if (startswith(src, "git@") || endswith(src, ".git")) {
                if(!isdir(ymp_source_cache + "/" + name)){
                    if (run_args({"git", "clone", "--bare",src, ymp_source_cache + "/" + name}) != 0) {
                        error_add(_("Failed to clone repository %s").printf(src));
                    }
                }
                foreach(string file in find(ymp_source_cache + "/" + name)){
                    copy_file(file, srcfile+"/.git/"+file[(ymp_source_cache + "/" + name).length:]);
                }
                string cur = pwd();
                cd(srcfile+"/.git");
                run_args({"git", "config", "--unset", "core.bare"});
                cd(srcfile);
                run_args({"git", "reset", "--hard"});
                cd(cur);
            } else if ("://" in src) {
                info(_("Download: %s").printf(src));
                fetch(src, ymp_source_cache + "/" + name);
                copy_file(ymp_source_cache + "/" + name, srcfile);
            } else {
                error_add("File %s does not exists.".printf(src));
            }
            string hash = "";
            if(algo == "md5sum"){
                hash = calculate_md5sum(srcfile);
            } else if(algo == "sha256sum"){
                hash = calculate_sha256sum(srcfile);
            }
            if (sums[i] != hash && sums[i] != "SKIP") {
                remove_all(ymp_source_cache + "/" + name);
                error_add(_("%s check failed. Excepted: %s <> Reveiced: %s").printf(algo, sums[i], hash));
            }
            i++;
        }
        return (!has_error());
    }

    public bool extract_package_sources() {
        string curdir = pwd();
        cd(ymp_build.ympbuild_buildpath);
        print(colorize(_("Extracting package resources from:"), yellow) + ymp_build.ympbuild_buildpath);
        if (ymp_build.get_ympbuild_value("noextract") != ""){
            return true;
        }
        var tar = new archive();
        foreach(string src in ymp_build.get_ympbuild_array("source")) {
            if (src == "") {
                continue;
            }
            string srcfile = sbasename(src);
            if ("::" in src){
                srcfile = ssplit(src,"::")[0];
            }
            if (tar.is_archive(srcfile)) {
                tar.load(srcfile);
                tar.set_target(ymp_build.ympbuild_buildpath);
                tar.extract_all();
            }
        }
        cd(curdir);
        return true;
    }

    public bool build_package() {
        print(colorize(_("Building package from:"), yellow) + ymp_build.ympbuild_buildpath);
        string curdir = pwd();
        cd(ymp_build.ympbuild_buildpath);
        int status = 0;
        if (!get_bool("no-build")) {
            string[] build_actions = {
                "prepare",
                "setup",
                "build"
            };
            foreach(string func in build_actions) {
                info(_("Running build action: %s").printf(func));
                status = ymp_build.run_ympbuild_function(func);
                if (status != 0) {
                    error_add(_("Failed to build package. Action: %s").printf(func));
                    cd(curdir);
                    return false;
                }
            }
        }
        if (!get_bool("no-package")) {
            string[] install_actions = {
                "test",
                "package"
            };
            foreach(string func in install_actions) {
                info("Running build action: " + func);
                status = ymp_build.run_ympbuild_function(func);
                if (status != 0) {
                    error_add(_("Failed to build package. Action: %s").printf(func));
                    cd(curdir);
                    return false;
                }
            }
            ymp_build.ymp_process_binaries();
        }
        if(!build_target.create_files_info()){
            cd(curdir);
            return false;
        }
        cd(curdir);
        return true;
    }
}
