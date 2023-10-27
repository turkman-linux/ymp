public class build_target_ymp {

        public builder bd;
        public string suffix = "ymp";
        public build_target_ymp(builder build){
            bd = build;
        }

        public string create_source_archive () {
            print (colorize (_ ("Create source package from :"), yellow) + bd.yb.ympbuild_srcpath);
            string curdir = pwd ();
            cd (bd.yb.ympbuild_srcpath);
            string metadata = bd.yb.get_ympbuild_metadata ();
            writefile (srealpath (bd.yb.ympbuild_buildpath + "/metadata.yaml"), metadata.strip () + "\n");
            var tar = new archive ();
            tar.load (bd.yb.ympbuild_buildpath + "/source.zip");
            foreach (string file in bd.yb.get_ympbuild_array ("source")) {
                if (!endswith (file, ".ymp") && isfile (file)) {
                    file = file[ (bd.yb.ympbuild_srcpath).length:];
                    create_dir (sdirname (bd.yb.ympbuild_buildpath + "/" + file));
                    copy_file (bd.yb.ympbuild_srcpath + file, bd.yb.ympbuild_buildpath + file);
                }
            }
            copy_file (bd.yb.ympbuild_srcpath + "/ympbuild", bd.yb.ympbuild_buildpath + "/ympbuild");
            cd (bd.yb.ympbuild_buildpath);
            tar.add ("metadata.yaml");
            foreach (string file in find (bd.yb.ympbuild_buildpath)) {
                file = file[ (bd.yb.ympbuild_buildpath).length:];
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
            return bd.yb.ympbuild_buildpath + "/source.zip";
        }

        public bool create_files_info () {
            string curdir = pwd ();
            cd (bd.yb.ympbuild_buildpath + "/output");
            string files_data = "";
            string links_data = "";
            bool unsafe = get_bool ("unsafe");
            foreach (string path in listdir (bd.yb.ympbuild_buildpath + "/output")) {
                if (path == "metadata.yaml" || path == "icon.svg") {
                    continue;
                }
                string fpath = bd.yb.ympbuild_buildpath + "/output/" + path;
                if (issymlink (fpath)) {
                    continue;
                }else if (!unsafe && isfile (fpath)) {
                    error_add (_ ("Files are not allowed in root directory: /%s").printf (path));
                }
            }
            foreach (string file in find (bd.yb.ympbuild_buildpath + "/output")) {
                if (" " in file) {
                    continue;
                }
                if (isdir (file)) {
                    continue;
                }
                if (!unsafe && filesize (file) == 0) {
                    warning (_ ("Empty file detected: %s").printf (file));
                }
                if (issymlink (file)) {
                    var link = sreadlink (file);
                    if (!unsafe && link[0] == '/') {
                        error_add (_ ("Absolute path symlink is not allowed:%s%s => %s").printf ("\n    ", file, link));
                        continue;
                    }
                    if (!unsafe && !isexists (sdirname (file) + "/" + link) && link.length > 0) {
                        error_add (_ ("Broken symlink detected:%s%s => %s").printf ("\n    ", file, link));
                        continue;
                    }
                    file = file[ (bd.yb.ympbuild_buildpath + "/output/").length:];
                    debug (_ ("Link info add: %s").printf (file));
                    links_data += file + " " + link + "\n";
                    continue;
                }else {
                    file = file[ (bd.yb.ympbuild_buildpath + "/output/").length:];
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
            writefile (bd.yb.ympbuild_buildpath + "/output/files", files_data);
            writefile (bd.yb.ympbuild_buildpath + "/output/links", links_data);
            cd (curdir);
            return true;
        }
        public bool create_metadata_info () {
            string metadata = bd.yb.get_ympbuild_metadata ();
            bool unsafe = get_bool ("unsafe");
            debug ("Create metadata info: " + bd.yb.ympbuild_buildpath + "/output/metadata.yaml");
            var yaml = new yamlfile ();
            yaml.data = metadata;
            string srcdata = yaml.get ("ymp.source");
            string name = yaml.get_value (srcdata, "name");
            string release = yaml.get_value (srcdata, "release");
            string version = yaml.get_value (srcdata, "version");
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
            if (unsafe) {
                new_data += "    unsafe: true/n";
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
            bool arch_is_supported = false;
            foreach (string a in yaml.get_array (srcdata, "arch")) {
                if (a == getArch ()) {
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
            bd.output_package_name = name + "_" + version + "_" + release;
            create_dir(bd.yb.ympbuild_buildpath + "/output/");
            writefile (bd.yb.ympbuild_buildpath + "/output/metadata.yaml", trim (new_data));
            return true;
        }

        public void create_data_file () {
            debug (_ ("Create data file: %s/output/data.tar.gz").printf (bd.yb.ympbuild_buildpath));
            var tar = new archive ();
            if (get_value ("compress") == "none") {
                      set_archive_type ("tar", "none");
                      tar.load (bd.yb.ympbuild_buildpath + "/output/data.tar");
            }else if (get_value ("compress") == "gzip") {
                      set_archive_type ("tar", "gzip");
                      tar.load (bd.yb.ympbuild_buildpath + "/output/data.tar.gz");
            }else if (get_value ("compress") == "xz") {
                      set_archive_type ("tar", "xz");
                      tar.load (bd.yb.ympbuild_buildpath + "/output/data.tar.xz");
            }else {
                      // Default format (gzip)
                      set_archive_type ("tar", "gzip");
                      tar.load (bd.yb.ympbuild_buildpath + "/output/data.tar.gz");
            }
            int fnum = 0;
            foreach (string file in find (bd.yb.ympbuild_buildpath + "/output")) {
                if (isdir (file)) {
                    continue;
                }
                file = file[ (bd.yb.ympbuild_buildpath + "/output/").length:];
                debug (_ ("Compress: %s").printf (file));
                if (file == "files" || file == "links" || file == "metadata.yaml" || file == "icon.svg") {
                    continue;
                }
                tar.add (file);
                fnum++;
            }
            if (isfile (bd.yb.ympbuild_buildpath + "/output/data.tar.gz")) {
                remove_file (bd.yb.ympbuild_buildpath + "/output/data.tar.gz");
            }
            if (fnum != 0) {
                set_archive_type ("tar", "gzip");
                tar.create ();
            }
            string hash = calculate_sha1sum (bd.yb.ympbuild_buildpath + "/output/data.tar.gz");
            int size = filesize (bd.yb.ympbuild_buildpath + "/output/data.tar.gz");
            string new_data = readfile (bd.yb.ympbuild_buildpath + "/output/metadata.yaml");
            new_data += "    archive-hash: " + hash + "\n";
            new_data += "    arch: " + getArch () + "\n";
            new_data += "    archive-size: " + size.to_string () + "\n";
            writefile (bd.yb.ympbuild_buildpath + "/output/metadata.yaml", trim (new_data));

        }

        public string create_binary_package () {
            print (colorize (_ ("Create binary package from: %s"), yellow).printf (bd.yb.ympbuild_buildpath));
            string curdir = pwd ();
            cd (bd.yb.ympbuild_buildpath + "/output");
            create_data_file ();
            var tar = new archive ();
            tar.load (bd.yb.ympbuild_buildpath + "/package.zip");
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
            return bd.yb.ympbuild_buildpath + "/package.zip";
        }
}
