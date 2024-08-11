private static int revdep_rebuild_main (string[] args) {
    setenv ("LANG", "C", 1);
    setenv ("LC_ALL", "C", 1);
    if (get_bool ("pkgconfig")) {
        writefile ("/tmp/.empty.c", "");
        foreach (string name in ssplit (getoutput ("pkg-config --list-package-names"), "\n")) {
            check_pkgconfig (name);
        }
        remove_file ("/tmp/.empty.c");
        print_fn ("\x1b[2K\r", false, true);
    }else if (get_bool ("detect-file-dep")) {
        foreach (string arg in args) {
            print (join("\n", detect_file_dep (arg)));
        }
    }else if (get_bool ("detect-dep")) {
        foreach (string arg in args) {
            info (colorize (_ ("Detect dependencies for:"), green) + " %s".printf (arg));
            string[] flist = {};
            if (iself (arg)) {
                flist = detect_file_dep (arg);
            }else {
                flist = detect_dep (arg);
            }
            string[] nlist = {};
            foreach(string l in flist){
                nlist += sbasename(l);
            }
            var deps = new array ();
            foreach (string pkg in search_elf (nlist)) {
                if (!deps.has (pkg)) {
                    deps.add (pkg);
                }
            }
            if (deps.has (arg)) {
                deps.remove(arg);
            }
            if (deps.has ("glibc")) {
                deps.remove("glibc");
            }
            print (join(" ", deps.get ()));
            if(is_installed_package(arg)){
                package p = get_installed_package(arg);
                array misssing = new array();
                foreach(string d in deps.get()){
                    if(!(d in p.dependencies)){
                        misssing.add(d);
                    }
                }
                misssing.remove(arg);
                if(misssing.length() > 0){
                    warning(_("Misssing dependencies detected: %s => %s").printf(arg, join(" ",misssing.get())));
                }
            }
        }
    }else {
        string[] paths = {
            "/lib", "/lib64", "/usr/lib", "/usr/lib64",
            "/lib32", "/usr/lib32", "/libx32", "/usr/libx32",
        };
        foreach (string path in paths) {
            foreach (string file in find (path)) {
                if (endswith (file, ".so")) {
                    check (file);
                }
            }
        }
        paths = {"/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/libexec"};
        foreach (string path in paths) {
            foreach (string file in find (path)) {
                check (file);
            }
        }
        print_fn ("\x1b[2K\r", false, true);
    }
    return 0;
}

private static void check (string file) {
    print_fn ("\x1b[2K\r" + _ ("Checking: %s").printf (sbasename (file)), false, true);
    string lddout = getoutput ("ldd '%s' 2>/dev/null".printf (file));
    foreach (string line in ssplit(lddout,"\n")) {
        line = line.strip();
        if (endswith (line, "not found")) {
            string missing = ssplit(line," ")[0];
            if (missing in get_ldd_dep(file)){
                print_fn ("\x1b[2K\r", false, true);
                print ("%s => %s (%s)".printf (colorize (file, red), missing, join (" ", search_file ( {file}))));
            }
        }
    }
}


private static void check_pkgconfig (string name) {
    print_fn ("\x1b[2K\r" + _ ("Checking: %s").printf (name), false, true);
    int status = run ("gcc `pkg-config --cflags --libs " + name + " 2>/dev/null` /tmp/.empty.c -shared -o /dev/null 2>/dev/null");
    if (status != 0) {
        print_fn ("\x1b[2K\r", false, true);
        print (_ ("%s broken.").printf (colorize (name, red)));
    }
}


private static string[] detect_dep (string pkgname) {
    if (!is_installed_package (pkgname)) {
        error_add (_ ("%s is not an installed package.").printf (pkgname));
        return {};
    }
    var depfiles = new array ();
    string files=readfile_cached ("%s/files/%s".printf (get_storage (), pkgname));
    foreach (string line in ssplit (files, "\n")) {
        string path="/" + line[41:];
        if (iself (path)) {
            foreach (string dep in detect_file_dep (path)) {
                if (!depfiles.has (dep)) {
                    depfiles.add (dep);
                }
            }
        }
    }
    return depfiles.get ();
}

private static string[] get_ldd_dep (string path) {
    if (!iself (path)) {
        return {};
    }
    string lddout=getoutput ("readelf -d '%s' 2>/dev/null".printf (path));
    var depfiles = new array ();
    foreach (string ldline in ssplit (lddout, "\n")) {
        if ("NEEDED" in ldline) {
            string fdep = ldline.strip ().split ("[")[1][0:-1];
            fdep = get_ld_path(fdep);
            if (!depfiles.has (fdep)) {
                depfiles.add (fdep);
            }
        }
    }

    return depfiles.get ();
}

private static string ldcache = null;
public string get_ld_path(string dep){
    if (ldcache == null){
        ldcache = getoutput ("/sbin/ldconfig -p");
    }
    foreach (string line in ssplit (ldcache, "\n")) {
        if (endswith(line,dep)){
            string ret = line.strip ().split (" ")[3];
            return ret;
        }
    }
    return dep;
}

private static string[] detect_file_dep(string path) {
    if(!iself(path)){
        return {};
    }
    array base_arr = new array();
    array rm_list = new array();
    base_arr.adds(get_ldd_dep(path));
    foreach(string dep in base_arr.get()){
        string[] sub = get_ldd_dep(dep);
        foreach(string f in sub){
            if(!rm_list.has(f)){
                rm_list.add(f);
            }
        }
    }
    foreach(string dep in rm_list.get()){
        if(base_arr.has(dep)){
            base_arr.remove(dep);
        }
    }
    return base_arr.get();
}

static void revdep_rebuild_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (revdep_rebuild_main);
    op.names = {_ ("revdep-rebuild"), "revdep-rebuild", "rbd"};
    op.help.name = _ ("revdep-rebuild");
    op.help.description = _ ("Check library for broken links.");
    op.help.add_parameter ("--pkgconfig", _ ("check pkgconfig files"));
    op.help.add_parameter ("--detect-dep", _ ("detect package dependencies"));
    op.help.add_parameter ("--detect-file-dep", _ ("detect file dependencies"));
    add_operation (op);
}
