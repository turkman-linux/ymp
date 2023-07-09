public class builder {

        public builder () {
            yb = new ympbuild ();
        }

        public ympbuild yb;
        public string output;
        public int build_single (string path) {
            string srcpath=srealpath (path);
            string srcpkg = "";
            string binpkg = "";
            output= get_value ("output");
            if (output == "") {
                output=srealpath (srcpath);
            }else {
                output=srealpath (output);
            }
            if (!isdir (output)) {
                create_dir (output);
            }

            if (startswith (path, "git://") || endswith (path, ".git")) {
                srcpath=DESTDIR + BUILDDIR + sbasename (path);
                if (isdir (srcpath)) {
                    remove_all (srcpath);
                }
                if (run ("git clone '" + path + "' " + srcpath) != 0) {
                    error_add (_ ("Failed to fetch git package."));
                    return 2;
                }
            }else if (startswith (path, "http://") || startswith (path, "https://")) {
                string file=DESTDIR + BUILDDIR + "/.cache/" + sbasename (path);
                create_dir (file);
                string farg = file + "/" + sbasename (path);
                if (!isfile (farg)) {
                    fetch (path, farg);
                }
                srcpath=farg;
            }
            if (isfile (srcpath)) {
                srcpath = DESTDIR + BUILDDIR + calculate_md5sum (srcpath);
                var tar = new archive ();
                tar.load (srcpath);
                tar.set_target (srcpath);
                tar.extract_all ();
                if (!isfile (srcpath + "/ympbuild")) {
                    error_add (_ ("Package is invalid: %s").printf (path));
                    remove_all (srcpath);
                    return 2;
                }
            }
            if (!isfile (srcpath + "/ympbuild")) {
                return 0;
            }
            if (!set_build_target (srcpath)) {
                return 1;
            }
            if (!create_metadata_info ()) {
                return 1;
            }
            // Set build target again (emerge change build target)
            yb.set_ympbuild_srcpath (srcpath);
            string build_path = srealpath (get_build_dir () + calculate_md5sum (srcpath + "/ympbuild"));
            yb.set_ympbuild_buildpath (build_path);


            info ("Check build dependencies");
            if (!check_build_dependencies ( {srcpath})) {
                return 1;
            }
            info ("Fetch sources");
            if (!fetch_package_sources ()) {
                return 2;
            }
            if (!get_bool ("no-source")) {
                info ("Create source package");
                srcpkg = create_source_archive ();
                if (srcpkg == "") {
                    return 1;
                }
                string target = output + "/" + output_package_name + "_source.ymp";
                move_file (srcpkg, target);
            }
            if (!get_bool ("no-binary")) {
                info ("Create binary package");
                if (!extract_package_sources ()) {
                    return 3;
                }
                if (!build_package ()) {
                    return 1;
                }
                binpkg = create_binary_package ();
                if (binpkg == "") {
                    return 1;
                }
                if (get_bool ("install")) {
                    if (0 != install_main ( {binpkg})) {
                        return 1;
                    }
                }
                string target = output + "/" + output_package_name + "_" + getArch () + ".ymp";
                move_file (binpkg, target);
            }
            return 0;
        }

        public bool check_build_dependencies (string[] args) {
          if (get_bool ("ignore-dependency")) {
                  return true;
            }
            string metadata = yb.get_ympbuild_metadata ();
            var yaml = new yamlfile ();
            yaml.data = metadata;
            yaml.data = yaml.get ("ymp.source");
            var deps = new array ();
            deps.adds (yaml.get_array (yaml.data, "makedepends"));
            deps.adds (yaml.get_array (yaml.data, "depends"));
            string name = yaml.get_value (yaml.data, "name");
            string[] use_flags = ssplit (get_value ("use"), " ");
            string package_use = get_config ("package.use", name);
            if (package_use.length > 0) {
                use_flags = ssplit (package_use, " ");
            }
            if ("all" in use_flags) {
                use_flags=yaml.get_array (yaml.data, "use-flags");
            }
            foreach (string flag in use_flags) {
                deps.adds (yaml.get_array (yaml.data, flag + "-depends"));
            }
            string[] pkgs = resolve_dependencies (deps.get ());
            string[] need_install = {};
            foreach (string pkg in pkgs) {
                info (join (" ", pkgs));
                if (pkg in args || pkg == name) {
                    continue;
                }else if (is_installed_package (pkg)) {
                    continue;
                }else {
                    need_install += pkg;
                }
            }
            if (need_install.length > 0) {
                error_add (_ ("Packages is not installed: %s").printf (join (" ", need_install)));
            }
            return (!has_error ());
        }

        public bool set_build_target (string src_path) {
            yb.set_ympbuild_srcpath (src_path);
            string build_path = srealpath (get_build_dir () + calculate_md5sum (yb.ympbuild_srcpath + "/ympbuild"));
            remove_all (build_path);
            yb.set_ympbuild_buildpath (build_path);
            if (isdir (build_path)) {
                remove_all (build_path);
            }
            if (!yb.ympbuild_check ()) {
                error_add (_ ("ympbuild file is invalid!"));
                return false;
            }
            return true;
        }

        public bool fetch_package_sources () {
            int i = 0;
            if (no_src) {
                return true;
            }
            string[] md5sums = yb.get_ympbuild_array ("md5sums");
            foreach (string src in yb.get_ympbuild_array ("source")) {
                if (src == "" || md5sums[i] == "") {
                    continue;
                }
                string srcfile = yb.ympbuild_buildpath + "/" + sbasename (src);
                string ymp_source_cache = DESTDIR + BUILDDIR + "/.cache/" + yb.get_ympbuild_value ("name") + "/";
                create_dir (ymp_source_cache);
                if (isfile (srcfile)) {
                    info (_ ("Source file already exists."));
                }else if (isfile (ymp_source_cache + "/" + sbasename (src))) {
                    info (_ ("Source file import from cache."));
                    copy_file (ymp_source_cache + "/" + sbasename (src), srcfile);
                }else if (isfile (yb.ympbuild_srcpath + "/" + src)) {
                    info (_ ("Source file copy from cache."));
                    copy_file (yb.ympbuild_srcpath + "/" + src, srcfile);
                }else {
                    info (_ ("Download: %s").printf (src));
                    fetch (src, ymp_source_cache + "/" + sbasename (src));
                    copy_file (ymp_source_cache + "/" + sbasename (src), srcfile);
                }
                string md5 = calculate_md5sum (srcfile);
                if (md5sums[i] != md5 && md5sums[i] != "SKIP") {
                    remove_all (ymp_source_cache + "/" + sbasename (src));
                    error_add (_ ("md5sum check failed. Excepted: %s <> Reveiced: %s").printf (md5sums[i], md5));
                }
                i++;
            }
            return (!has_error ());
        }

        public bool extract_package_sources () {
            string curdir = pwd ();
            cd (yb.ympbuild_buildpath);
            print (colorize (_ ("Extracting package resources from:"), yellow) + yb.ympbuild_buildpath);
            var tar = new archive ();
            foreach (string src in yb.get_ympbuild_array ("source")) {
                if (src == "") {
                    continue;
                }
                string srcfile = sbasename (src);
                if (tar.is_archive (srcfile)) {
                    tar.load (srcfile);
                    tar.extract_all ();
                }
            }
            cd (curdir);
            return true;
        }

        public bool build_package () {
            print (colorize (_ ("Building package from:"), yellow) + yb.ympbuild_buildpath);
            string curdir = pwd ();
            cd (yb.ympbuild_buildpath);
            int status = 0;
            if (!get_bool ("no-build")) {
                string[] build_actions = {"prepare", "setup", "build"};
                foreach (string func in build_actions) {
                    info (_ ("Running build action: %s").printf (func));
                    status = yb.run_ympbuild_function (func);
                    if (status != 0) {
                        error_add (_ ("Failed to build package. Action: %s").printf (func));
                        cd (curdir);
                        return false;
                    }
                }
            }
            if (!get_bool ("no-package")) {
                string[] install_actions = {"test", "package"};
                foreach (string func in install_actions) {
                    info ("Running build action: " + func);
                    status = yb.run_ympbuild_function (func);
                    if (status != 0) {
                        error_add (_ ("Failed to build package. Action: %s").printf (func));
                        cd (curdir);
                        return false;
                    }
                }
                yb.ymp_process_binaries ();
            }
            create_files_info ();
            cd (curdir);
            return true;
        }

        public string create_source_archive () {
            print (colorize (_ ("Create source package from :"), yellow) + yb.ympbuild_srcpath);
            string curdir = pwd ();
            cd (yb.ympbuild_srcpath);
            string metadata = yb.get_ympbuild_metadata ();
            writefile (srealpath (yb.ympbuild_buildpath + "/metadata.yaml"), metadata.strip () + "\n");
            var tar = new archive ();
            tar.load (yb.ympbuild_buildpath + "/source.zip");
            foreach (string file in yb.get_ympbuild_array ("source")) {
                if (!endswith (file, ".ymp") && isfile (file)) {
                    file = file[ (yb.ympbuild_srcpath).length:];
                    create_dir (sdirname (yb.ympbuild_buildpath + "/" + file));
                    copy_file (yb.ympbuild_srcpath + file, yb.ympbuild_buildpath + file);
                }
            }
            copy_file (yb.ympbuild_srcpath + "/ympbuild", yb.ympbuild_buildpath + "/ympbuild");
            cd (yb.ympbuild_buildpath);
            tar.add ("metadata.yaml");
            foreach (string file in find (yb.ympbuild_buildpath)) {
                file = file[ (yb.ympbuild_buildpath).length:];
                if (file[0] == '/') {
                    file = file[1:];
                }
                if (file == "metadata.yaml") {
                    continue;
                }
                if (file == null || file == "" || startswith (file, "output")) {
                    continue;
                }
                tar.add (file);
            }
            set_archive_type ("zip", "none");
            tar.create ();
            cd (curdir);
            return yb.ympbuild_buildpath + "/source.zip";
        }

        public bool create_files_info () {
            string curdir = pwd ();
            cd (yb.ympbuild_buildpath + "/output");
            string files_data = "";
            string links_data = "";
            foreach (string path in listdir (yb.ympbuild_buildpath + "/output")) {
                if (path == "metadata.yaml" || path == "icon.svg") {
                    continue;
                }
                string fpath = yb.ympbuild_buildpath + "/output/" + path;
                if (issymlink (fpath)) {
                    continue;
                }else if (isfile (fpath)) {
                    error_add (_ ("Files are not allowed in root directory: /%s").printf (path));
                }
            }
            foreach (string file in find (yb.ympbuild_buildpath + "/output")) {
                if (" " in file) {
                    continue;
                }
                if (isdir (file)) {
                    continue;
                }
                if (filesize (file) == 0) {
                    warning (_ ("Empty file detected: %s").printf (file));
                }
                if (issymlink (file)) {
                    var link = sreadlink (file);
                    if (link[0] == '/') {
                        error_add (_ ("Absolute path symlink is not allowed:%s%s => %s").printf ("\n    ", file, link));
                        continue;
                    }
                    if (!isexists (sdirname (file) + "/" + link) && link.length > 0) {
                        error_add (_ ("Broken symlink detected:%s%s => %s").printf ("\n    ", file, link));
                        continue;
                    }
                    file = file[ (yb.ympbuild_buildpath + "/output/").length:];
                    debug (_ ("Link info add: %s").printf (file));
                    links_data += file + " " + link + "\n";
                    continue;
                }else {
                    file = file[ (yb.ympbuild_buildpath + "/output/").length:];
                    if (file == "metadata.yaml" || file == "icon.svg") {
                        continue;
                    }
                    debug (_ ("File info add: %s").printf (file));
                    files_data += calculate_sha1sum (file) + " " + file + "\n";
                }
            }
            if (has_error ()) {
                cd (curdir);
                return false;
            }
            writefile (yb.ympbuild_buildpath + "/output/files", files_data);
            writefile (yb.ympbuild_buildpath + "/output/links", links_data);
            cd (curdir);
            return true;
        }
        public string output_package_name;
        public bool create_metadata_info () {
            string metadata = yb.get_ympbuild_metadata ();
            debug ("Create metadata info: " + yb.ympbuild_buildpath + "/output/metadata.yaml");
            var yaml = new yamlfile ();
            yaml.data = metadata;
            string srcdata = yaml.get ("ymp.source");
            string name = yaml.get_value (srcdata, "name");
            string release = yaml.get_value (srcdata, "release");
            string version = yaml.get_value (srcdata, "version");
            if (get_bool ("ignore-dependency")) {
                warning (_ ("Dependency check disabled"));
            }else {
                var need_install = new array ();
                if (yaml.has_area (srcdata, "depends")) {
                    foreach (string dep in yaml.get_array (srcdata, "depends")) {
                        if (!is_installed_package (dep)) {
                            if (get_bool ("install")) {
                                need_install.add (dep);
                            }else {
                                error_add (_ ("Package %s in not satisfied. Required by: %s").printf (dep, name));
                            }
                        }
                    }
                }
                if (yaml.has_area (srcdata, "makedepends")) {
                    foreach (string dep in yaml.get_array (srcdata, "makedepends")) {
                        if (!is_installed_package (dep)) {
                            if (get_bool ("install")) {
                                need_install.add (dep);
                            }else {
                                error_add (_ ("Package %s in not satisfied. Required by: %s").printf (dep, name));
                            }
                        }
                    }
                }
                if (has_error ()) {
                    return false;
                }
                string curdir = pwd ();
                if (get_bool ("install")) {
                    install_main (need_install.get ());
                }
                cd (curdir);
            }
            no_src = false;
            if (!yaml.has_area (srcdata, "archive")) {
                no_src = true;
                warning (_ ("Source array is not defined."));
            }
            string new_data = "ymp:\n";
            new_data += "  package:\n";
            string[] attrs = {"name", "version", "release", "description"};
            foreach (string attr in attrs) {
                new_data += "    " + attr + ": " + yaml.get_value (srcdata, attr) + "\n";
            }

            string[] arrys = {"provides", "replaces", "group"};
            foreach (string arr in arrys) {
                if (!yaml.has_area (srcdata, arr)) {
                    continue;
                }
                string[] deps = yaml.get_array (srcdata, arr);
                if (deps.length > 0) {
                    new_data += "    " + arr + ":\n";
                    foreach (string dep in deps) {
                        new_data += "     - " + dep + "\n";
                    }
                }
            }
            // calculate dependency list by use flag and base dependencies
            var deps = new array ();
            if (yaml.has_area (srcdata, "depends")) {
                deps.adds (yaml.get_array (srcdata, "depends"));
            }
            string[] use_flags = ssplit (get_value ("use"), " ");
            string package_use = get_config ("package.use", name);
            if (package_use.length > 0) {
                use_flags = ssplit (package_use, " ");
            }
            if ("all" in use_flags) {
                use_flags = yaml.get_array (srcdata, "use-flags");
            }
            if (yaml.has_area (srcdata, "use-flags")) {
                foreach (string flag in use_flags) {
                    info (_ ("Add use flag dependency: %s").printf (flag));
                    string[] fdeps = yaml.get_array (srcdata, flag + "-depends");
                    if (fdeps.length > 0) {
                        deps.adds (fdeps);
                    }
                }
            }
            if (deps.length () > 0) {
                new_data += "    depends:\n";
                foreach (string dep in deps.get ()) {
                    new_data += "     - " + dep + "\n";
                }
            }
            if (release == "") {
                error_add (_ ("Release is not defined."));
            }
            if (version == "") {
                error_add (_ ("Version is not defined."));
            }
            if (name == "") {
                error_add (_ ("Name is not defined."));
            }
            string arch = getArch ();
            bool arch_is_supported = false;
            foreach (string a in yaml.get_array (srcdata, "arch")) {
                if (a == arch) {
                    arch_is_supported = true;
                    break;
                }
            }
            if (!arch_is_supported) {
                error_add (_ ("Package architecture is not supported."));
            }
            if (has_error ()) {
                return false;
            }
            output_package_name = name + "_" + version + "_" + release;
            writefile (yb.ympbuild_buildpath + "/output/metadata.yaml", trim (new_data));
            return true;
        }

        public void create_data_file () {
            debug (_ ("Create data file: %s/output/data.tar.gz").printf (yb.ympbuild_buildpath));
            var tar = new archive ();
            if (get_value ("compress") == "none") {
                      set_archive_type ("tar", "none");
                      tar.load (yb.ympbuild_buildpath + "/output/data.tar");
            }else if (get_value ("compress") == "gzip") {
                      set_archive_type ("tar", "gzip");
                      tar.load (yb.ympbuild_buildpath + "/output/data.tar.gz");
            }else if (get_value ("compress") == "xz") {
                      set_archive_type ("tar", "xz");
                      tar.load (yb.ympbuild_buildpath + "/output/data.tar.xz");
            }else {
                      // Default format (gzip)
                      set_archive_type ("tar", "gzip");
                      tar.load (yb.ympbuild_buildpath + "/output/data.tar.gz");
            }
            int fnum = 0;
            foreach (string file in find (yb.ympbuild_buildpath + "/output")) {
                if (isdir (file)) {
                    continue;
                }
                file = file[ (yb.ympbuild_buildpath + "/output/").length:];
                debug (_ ("Compress: %s").printf (file));
                if (file == "files" || file == "links" || file == "metadata.yaml" || file == "icon.svg") {
                    continue;
                }
                tar.add (file);
                fnum++;
            }
            if (isfile (yb.ympbuild_buildpath + "/output/data.tar.gz")) {
                remove_file (yb.ympbuild_buildpath + "/output/data.tar.gz");
            }
            if (fnum != 0) {
                set_archive_type ("tar", "gzip");
                tar.create ();
            }
            string hash = calculate_sha1sum (yb.ympbuild_buildpath + "/output/data.tar.gz");
            int size = filesize (yb.ympbuild_buildpath + "/output/data.tar.gz");
            string new_data = readfile (yb.ympbuild_buildpath + "/output/metadata.yaml");
            new_data += "    archive-hash: " + hash + "\n";
            new_data += "    arch: " + getArch () + "\n";
            new_data += "    archive-size: " + size.to_string () + "\n";
            writefile (yb.ympbuild_buildpath + "/output/metadata.yaml", trim (new_data));

        }

        public string create_binary_package () {
            print (colorize (_ ("Create binary package from: %s"), yellow).printf (yb.ympbuild_buildpath));
            string curdir = pwd ();
            cd (yb.ympbuild_buildpath + "/output");
            create_data_file ();
            var tar = new archive ();
            tar.load (yb.ympbuild_buildpath + "/package.zip");
            tar.add ("metadata.yaml");
            tar.add ("files");
            tar.add ("links");
            if (isfile ("icon.svg")) {
                      tar.add ("icon.svg");
            }
            foreach (string path in listdir (".")) {
                if (isfile (path) && startswith (path, "data")) {
                    tar.add (path);
                }
            }
            set_archive_type ("zip", "none");
            tar.create ();
            cd (curdir);
            return yb.ympbuild_buildpath + "/package.zip";
        }
}
