//DOC: ## ympbuild file functions.
//DOC: ymp uses ympbuild format.

public class ympbuild {

        // private variables used by functions
        public string ympbuild_srcpath;
        public string ympbuild_buildpath;
        private string ympbuild_header;

        public void ympbuild_init () {
            if (ympbuild_srcpath == null) {
                ympbuild_srcpath = "./";
            }
            string jobs = get_value ("build:jobs");
            if (jobs == "0") {
                jobs = "`nproc`";
            }

            ympbuild_header = get_ympbuild_header ();
            ympbuild_header = ympbuild_header.replace ("@buildpath@", ympbuild_buildpath);
            ympbuild_header = ympbuild_header.replace ("@jobs@", jobs);
            ympbuild_header = ympbuild_header.replace ("@VERSION@", VERSION);
            ympbuild_header = ympbuild_header.replace ("@DISTRODIR@", DISTRODIR);
            ympbuild_header = ympbuild_header.replace ("@CFLAGS@", get_value ("build:cflags"));
            ympbuild_header = ympbuild_header.replace ("@CXXFLAGS@", get_value ("build:cxxflags"));
            ympbuild_header = ympbuild_header.replace ("@CC@", get_value ("build:cc"));
            ympbuild_header = ympbuild_header.replace ("@LDFLAGS@", get_value ("build:ldflags"));

            var use_flags = new array ();
            string[] flags = ssplit (get_value ("use"), " ");
            string name = get_ympbuild_value ("name");
            string package_use = get_config ("package.use", name);
            if (package_use.length > 0) {
                flags = ssplit (package_use, " ");
            }
            foreach (string flag in flags) {
               use_flags.add (flag);
               ympbuild_header += "declare -r use_'" + flag.replace ("'", "\\'") + "'=31 \n";

            }
            ympbuild_header += "declare -r use_" + getArch () + "=31 \n";
            print (colorize (_ ("USE flag: %s"), green).printf (join (" ", use_flags.get ())));
        }
        //DOC: `void set_ympbuild_srcpath (string path):`
        //DOC: configure ympbuild file directory
        public void set_ympbuild_srcpath (string path) {
            debug (_ ("Set ympbuild src path : %s").printf (path));
            ympbuild_srcpath = trim (srealpath (path));
        }

        //DOC: `void set_ympbuild_srcpath (string path):`
        //DOC: configure ympbuild file directory
        public void set_ympbuild_buildpath (string path) {
            ympbuild_buildpath = trim (srealpath (path));
            create_dir (ympbuild_buildpath);
            debug (_ ("Set ympbuild build path : %s").printf (ympbuild_buildpath));
            ympbuild_init ();
        }

        //DOC: `string get_ympbuild_value (string variable):`
        //DOC: get a variable from ympbuild file
        public string get_ympbuild_value (string variable) {
            if (ympbuild_srcpath == null) {
                ympbuild_srcpath = "./";
            }
            return getoutput ("env -i bash -c 'source " + ympbuild_srcpath + "/ympbuild >/dev/null ; echo ${" + variable + "[@]}'").strip ();
        }

        //DOC: `string[] get_ympbuild_array (string variable):`
        //DOC: get a array from ympbuild file
        public string[] get_ympbuild_array (string variable) {
            if (ympbuild_srcpath == null) {
                ympbuild_srcpath = "./";
            }
            return ssplit (getoutput ("env -i bash -c 'source " + ympbuild_srcpath + "/ympbuild >/dev/null ; echo ${" + variable + "[@]}'").strip (), " ");
        }

        //DOC: `bool ympbuild_has_function (string function):`
        //DOC: check ympbuild file has function
        public bool ympbuild_has_function (string function) {

            return 0 == run_args ( {"bash", "-c",
                "set +e ; source %s/ympbuild &>/dev/null; set -e; declare -F %s".printf (
                    ympbuild_srcpath,
                    function
                )
            });
        }

        public bool ympbuild_check () {
            info (_ ("Check ympbuild: %s/ympbuild").printf (ympbuild_srcpath));
            return 0 == run_args ( {"bash", "-n", ympbuild_srcpath + "/ympbuild"});
        }

        //DOC: `int run_ympbuild_function (string function):`
        //DOC: run a build function from ympbuild file
        public int run_ympbuild_function (string function) {
            if (function == "") {
                return 0;
            }
            set_terminal_title (_ ("Run action (%s) %s => %s").printf (
                sbasename (ympbuild_buildpath),
                get_ympbuild_value ("name"),
                function));
            if (ympbuild_has_function (function)) {
                string cmd = "%s \n set +e ; source %s/ympbuild ; export ACTION=%s ; set -e ; %s".printf (
                    ympbuild_header,
                    ympbuild_srcpath,
                    function,
                    function
                );
                if (get_bool ("quiet")) {
                    return run_args_silent ( {"bash", "-c", cmd});
                }else {
                    return run_args ( {"bash", "-c", cmd});
                }
            }else {
                warning (_ ("ympbuild function not exists: %s").printf (function));
            }
            return 0;
        }
        public void ymp_process_binaries () {
            string[] garbage_dirs = {STORAGEDIR, "/tmp", "/run", "/dev", "/data", "/home"};
            foreach (string dir in garbage_dirs) {
                if (isdir (ympbuild_buildpath + "/output/" + dir)) {
                    remove_all (ympbuild_buildpath + "/output/" + dir);
                }
            }
            if (get_ympbuild_value ("dontstrip") == "") {
                foreach (string file in find (ympbuild_buildpath + "/output")) {
                    if (endswith (file, ".a") || endswith (file, ".o")) {
                        // skip static library
                        info (_ ("Binary process skip for: %s").printf (file));
                        continue;
                    }
                    if (iself (file)) {
                        print (colorize (_ ("Binary process: %s"), magenta).printf (file[ (ympbuild_buildpath + "/output").length:]));
                        run_args ( {"objcopy", "-R", ".comment", "-R", ".note", "-R", ".debug_info",
                            "-R", ".debug_aranges", "-R", ".debug_pubnames", "-R", ".debug_pubtypes",
                            "-R", ".debug_abbrev", "-R", ".debug_line", "-R", ".debug_str",
                            "-R", ".debug_ranges", "-R", ".debug_loc", file});
                        run_args ( {"strip", file});
                    }
                }
            }
            foreach (string file in find (ympbuild_buildpath + "/lib64")) {
                if (iself (file) && !is64bit (file)) {
                    warning (_ ("File is not 64bit: %s").printf (file));
                }
            }
            foreach (string file in find (ympbuild_buildpath + "/usr/lib64")) {
                if (iself (file) && !is64bit (file)) {
                    warning (_ ("File is not 64bit: %s").printf (file));
                }
            }
            foreach (string file in find (ympbuild_buildpath + "/lib32")) {
                if (iself (file) && is64bit (file)) {
                    warning (_ ("File is not 32bit: %s").printf (file));
                }
            }
            foreach (string file in find (ympbuild_buildpath + "/usr/lib32")) {
                if (iself (file) && is64bit (file)) {
                    warning (_ ("File is not 32bit: %s").printf (file));
                }
            }
            if (isfile (ympbuild_buildpath + "/output/usr/share/info/dir")) {
                remove_file (ympbuild_buildpath + "/output/usr/share/info/dir");
            }
            foreach (string path in find (ympbuild_buildpath + "/output")) {
                if (endswith (path, ".pyc")) {
                    remove_file (path);
                }
            }
        }

        //DOC: `string get_ympbuild_metadata ():`
        //DOC: generate metadata.yaml content and return as string
        public string get_ympbuild_metadata () {
            return getoutput ("env -i bash -c '" + ympbuild_header + " source " + ympbuild_srcpath + "/ympbuild &>/dev/null ; ymp_print_metadata'");
        }
}
