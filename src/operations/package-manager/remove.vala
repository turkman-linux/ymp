private static int remove_main (string[] args) {
    if (!is_root ()) {
        error_add (_ ("You must be root!"));
        error (1);
    }
    single_instance ();
    set_value_readonly ("OPERATION", "prerm");
    sysconf_main (args);
    string[] pkgs = {};
    if (get_bool ("ignore-dependency")) {
        pkgs = args;
    }else {
        pkgs = resolve_reverse_dependencies (args);
    }
    if (get_bool("unsafe")){
        foreach (string name in  get_unsafe_packages()){
            pkgs += name;
        }
    }
    if ("ymp" in pkgs) {
        if (!get_bool ("ignore-safety")) {
            error_add (_ ("You cannot remove package manager! If you really want, must use --ignore-safety"));
            return 1;
        }
    }
    if (get_bool ("ask")) {
        print (_ ("The following additional packages will be removed:"));
        print (join (" ", pkgs));
        if (!yesno (colorize (_ ("Do you want to continue?"), red))) {
            return 1;
        }
    }else {
        info (_ ("Resolve reverse dependency done: %s").printf (join (" ", pkgs)));
    }
    foreach (string pkg in pkgs) {
        if (is_installed_package (pkg)) {
            package p = get_installed_package (pkg);
            remove_single (p);
        }else {
            warning (_ ("Package %s is not installed. Skip removing.").printf (pkg));
        }
    }
    set_value_readonly ("OPERATION", "postrm");
    sysconf_main (args);
    return 0;
}

private static int remove_single (package p) {
    print (colorize (_ ("Removing: %s"), yellow).printf (p.name));
    if (!get_bool ("without-files")) {
        foreach (string file in p.list_links ()) {
            if (file.length > 3) {
                file=ssplit (file, " ")[0];
                info (_ ("Removing: %s").printf (file));
                remove_file (DESTDIR + "/" + file);
            }
        }
        foreach (string file in p.list_files ()) {
            if (file.length > 41) {
                file=file[41:];
                info (_ ("Removing: %s").printf (file));
                remove_file (DESTDIR + "/" + file);
            }
        }
        foreach (string file in p.list_links ()) {
            if (file.length > 3) {
                file=ssplit (file, " ")[0];
                string dir = sdirname (file);
                if (is_empty_dir (DESTDIR + "/" + dir)) {
                    remove_dir (DESTDIR + "/" + dir);
                }
            }
        }
        foreach (string file in p.list_files ()) {
            if (file.length > 41) {
                file=file[41:];
                string dir = sdirname (file);
                if (is_empty_dir (DESTDIR + "/" + dir)) {
                    remove_dir (DESTDIR + "/" + dir);
                }
            }
        }
    }
    if (!get_bool ("without-metadata")) {
        remove_file (get_storage () + "/metadata/" + p.name + ".yaml");
        remove_file (get_storage () + "/files/" + p.name);
        remove_file (get_storage () + "/links/" + p.name);
        if (isdir (get_storage () + "/sysconf/" + p.name)) {
            remove_all (get_storage () + "/sysconf/" + p.name);
        }
    }
    return 0;
}

void remove_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (remove_main);
    op.names = {_ ("remove"), "remove", "rm"};
    op.help.name = _ ("remove");
    op.help.minargs=1;
    op.help.description = _ ("Remove package from package name.");
    op.help.add_parameter ("--ignore-dependency", _ ("disable dependency check"));
    op.help.add_parameter ("--without-files", _ ("do not remove files from package database"));
    op.help.add_parameter ("--unsafe", _ ("remove all unsafe packages"));
    op.help.add_parameter ("--without-metadata", _ ("do not remove metadata from package database"));
    add_operation (op);
}
