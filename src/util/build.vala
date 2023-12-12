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

public class builder {

    public builder() {
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
        backup_env();
        clear_env();
        set_env("PATH","/sbin:/bin:/usr/sbin:/usr/bin");

        string srcpath = srealpath(path);
        string srcpkg = "";
        string binpkg = "";
        output = get_value("output");
        if (output == "") {
            output = srealpath(srcpath);
        } else {
            output = srealpath(output);
        }
        if (!isdir(output)) {
            create_dir(output);
        }
        if (startswith(path, "git@") || endswith(path, ".git")) {
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
            string file = get_build_dir() + "/.cache/" + sbasename(path);
            create_dir(file);
            string farg = file + "/" + sbasename(path);
            if (!isfile(farg)) {
                fetch(path, farg);
            }
            srcpath = farg;
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
                restore_env();
                return 2;
            }
        }
        if (!isfile(srcpath + "/ympbuild")) {
            restore_env();
            return 0;
        }
        if (!set_build_target(srcpath)) {
            restore_env();
            return 1;
        }
        if (!build_target.create_metadata_info()) {
            restore_env();
            return 1;
        }
        // Set build target again (emerge change build target)
        ymp_build.set_ympbuild_srcpath(srcpath);
        string build_path = srealpath(get_build_dir() + "/" + calculate_md5sum(srcpath + "/ympbuild"));
        ymp_build.set_ympbuild_buildpath(build_path);

        info("Check build dependencies");
        if (!check_build_dependencies({srcpath})) {
            restore_env();
            return 1;
        }
        info("Fetch sources");
        if (!fetch_package_sources()) {
            restore_env();
            return 2;
        }
        if (!get_bool("no-source")) {
            info("Create source package");
            print(colorize(_("Create source package from :"), yellow) + ymp_build.ympbuild_srcpath);
            srcpkg = build_target.create_source_archive();
            if (srcpkg == "") {
                restore_env();
                return 1;
            }
            if (srcpkg != "ignore") {
                string target = output + "/" + output_package_name + "_source.ymp";
                move_file(srcpkg, target);
            }
        }
        if (!get_bool("no-binary")) {
            info("Create binary package");
            if (!extract_package_sources()) {
                restore_env();
                return 3;
            }
            if (!build_package()) {
                restore_env();
                return 1;
            }
            print(colorize(_("Create binary package from: %s"), yellow).printf(build_path));
            binpkg = build_target.create_binary_package();
            if (binpkg == "") {
                restore_env();
                return 1;
            }
            if (get_bool("install")) {
                if (0 != install_main({
                        binpkg
                    })) {
                    restore_env();
                    return 1;
                }
            }
            string target = output + "/" + output_package_name + "_" + build_target.arch + "." + build_target.suffix;
            move_file(binpkg, target);
        }
        restore_env();
        return 0;
    }

    public bool check_build_dependencies(string[] args) {
        if (get_bool("ignore-dependency")) {
            warning(_("Dependency check disabled"));
            return true;
        }
        backup_env();
        clear_env();
        set_env("PATH","/sbin:/bin:/usr/sbin:/usr/bin");

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
                install_main(need_install);
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
        string[] md5sums = ymp_build.get_ympbuild_array("md5sums");
        foreach(string src in ymp_build.get_ympbuild_array("source")) {
            if (src == "" || md5sums[i] == "") {
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
            if (isfile(srcfile)) {
                info(_("Source file already exists."));
            } else if (isfile(ymp_source_cache + "/" + name)) {
                info(_("Source file import from cache."));
                copy_file(ymp_source_cache + "/" + name, srcfile);
            } else if (isfile(ymp_build.ympbuild_srcpath + "/" + src)) {
                info(_("Source file copy from cache."));
                copy_file(ymp_build.ympbuild_srcpath + "/" + src, srcfile);
            } else {
                info(_("Download: %s").printf(src));
                fetch(src, ymp_source_cache + "/" + name);
                copy_file(ymp_source_cache + "/" + name, srcfile);
            }
            string md5 = calculate_md5sum(srcfile);
            if (md5sums[i] != md5 && md5sums[i] != "SKIP") {
                remove_all(ymp_source_cache + "/" + name);
                error_add(_("md5sum check failed. Excepted: %s <> Reveiced: %s").printf(md5sums[i], md5));
            }
            i++;
        }
        return (!has_error());
    }

    public bool extract_package_sources() {
        string curdir = pwd();
        cd(ymp_build.ympbuild_buildpath);
        print(colorize(_("Extracting package resources from:"), yellow) + ymp_build.ympbuild_buildpath);
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
