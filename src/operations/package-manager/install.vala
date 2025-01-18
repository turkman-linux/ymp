private static int install_main (string[] args) {
    save_env();
    clear_env();
    file_cache_reset();
    setenv("PATH","/sbin:/bin:/usr/sbin:/usr/bin", 1);

    if (!is_root ()) {
        error_add (_ ("You must be root!"));
        error (1);
    }
    if (!get_bool ("no-emerge") && usr_is_merged ()) {
        error_add (_ ("Install (from source) operation with usrmerge is not allowed!"));
        error (31);
    }
    single_instance ();
    set_value_readonly ("OPERATION", "preinst");
    sysconf_main (args);
    var a = new array ();
    a.adds (resolve_dependencies (args));
    if (get_bool ("upgrade")) {
        string[] up_pkgs = get_upgradable_packages ();
        a.adds (resolve_dependencies (up_pkgs));
    }
    string[] pkgs = a.get ();
    if (get_bool ("ask")) {
        print (_ ("The following additional packages will be installed:"));
        print (join (" ", pkgs));
        if (!yesno (colorize (_ ("Do you want to continue?"), red))) {
            return 1;
        }
    }else {
        info (_ ("Resolve dependency done: %s").printf (join (" ", pkgs)));
    }
    quarantine_reset ();
    jobs j = new jobs();
    foreach (string name in pkgs) {
        if (isfile (name)) {
            continue;
        }
        if (is_available_from_repository (name)) {
            package *p = get_from_repository (name);
            j.add((void*)p->download_only, p);
        }
    }
    j.run();
    if (get_bool ("download-only")) {
        return 0;
    }
    j = new jobs();
    foreach (string name in pkgs) {
        package *pkg = package_get_single (name);
        if (pkg == null) {
            error (1);
        }else {
            j.add((void*)package_extract_single, pkg);
        }
    }
    j.run();
    string[] leftovers = calculate_leftover (pkgs);
    if (!quarantine_validate ()) {
        error_add (_ ("Quarantine validation failed."));
    }
    error (1);
    quarantine_install ();
    quarantine_reset ();
    error (1);
    print (colorize (_ ("Clearing leftovers"), yellow));
    foreach (string file in leftovers) {
        remove_file (DESTDIR + "/" + file);
    }
    set_value_readonly ("OPERATION", "postinst");
    sysconf_main (args);
    restore_env();
    error (1);
    return 0;
}
private static package package_get_single (string pkg) {
    package p = null;
    // Download package files from repository
    if (isfile (pkg)) {
        info (_ ("Installing from package file: %s").printf (pkg));
        p = new package ();
        p.load_from_archive (srealpath (pkg));
    }else {
        info (_ ("Installing from repository: %s").printf (pkg));
        p = get_from_repository (pkg);
        p.download ();
    }
    if (p.is_source) {
        if (! (getArch () in p.gets ("arch"))) {
            error_add (_ ("Package architecture is not supported."));
        }
    }else {
        if (p.get ("arch") != getArch ()) {
            error_add (_ ("Package architecture is not supported."));
        }
    }
    error (2);
    if (p.is_source || get_bool ("sync-single")) {
        print (colorize (_ ("Building: %s"), yellow).printf (p.name));
        p.build ();
        if (!quarantine_validate ()) {
            error_add (_ ("Quarantine validation failed."));
            quarantine_reset ();
        }
        error (1);
        string[] leftovers = calculate_leftover ({p.name});
        quarantine_install ();
        quarantine_reset ();
        foreach (string file in leftovers) {
            remove_file (DESTDIR + "/" + file);
        }
        sysconf_main ( {});
    }
    return p;
}

private static void package_extract_single(package *p){
    if (!p->is_source) {
        print (colorize (_ ("Installing: %s"), yellow).printf (p->name));
        p->extract();
    }
}


private class leftover {
    public string[] files;
    public string name;
}

private static void calculate_leftover_single (leftover l){
    array files = new array();
    if (is_installed_package (l.name) && isfile(get_storage () + "/quarantine/metadata/" + l.name+".yaml")) {
         print (colorize (_ ("Calculating leftovers: %s"), yellow).printf (l.name));
         // installed files
         package pi = get_installed_package (l.name);
         foreach (string file in pi.list_files ()) {
             if (file.length > 41) {
                 files.add (file[41:]);
             }
         }
         // installed symlinks
         foreach (string link in pi.list_links ()) {
             files.add (ssplit (link, " ")[0]);
         }
         // new files
         foreach (string file in ssplit (readfile_cached (get_storage () + "/quarantine/files/" + l.name), "\n")) {
             if (file.length > 41) {
                 files.remove (file[41:]);
             }
         }
         //new symlinks
         foreach (string link in ssplit (readfile_cached (get_storage () + "/quarantine/links/" + l.name), "\n")) {
             files.remove (ssplit (link, " ")[0]);
         }
    }
    l.files = files.get();
}

private static string[] calculate_leftover (string[] pkgs) {
    print (colorize (_ ("Calculating leftovers"), yellow));
    // Fetch installed and new files list
    jobs j = new jobs();
    int i=0;
    leftover[] lft = new leftover[pkgs.length];
    foreach (string p in pkgs) {
        lft[i] = new leftover();
        lft[i].name = p;
        j.add((void*)calculate_leftover_single, lft[i]);
        i++;
    }
    j.run();
    var ret = new array();
    foreach (leftover l in lft) {
        ret.adds(l.files);
    }
    return ret.get ();
}
static void install_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (install_main);
    op.names = {_ ("install"), "install", "it", "add"};
    op.help.name = _ ("install");
    op.help.description = _ ("Install package from source or package file or repository");
    op.help.add_parameter ("--ignore-dependency", _ ("disable dependency check"));
    op.help.add_parameter ("--ignore-satisfied", _ ("ignore not satisfied packages"));
    op.help.add_parameter ("--sync-single", _ ("sync quarantine after every package installation"));
    op.help.add_parameter ("--download-only", _ ("download packages without installation"));
    op.help.add_parameter ("--reinstall", _ ("reinstall if already installed"));
    op.help.add_parameter ("--upgrade", _ ("upgrade all packages"));
    op.help.add_parameter ("--no-emerge", _ ("use binary packages"));
    add_operation (op);
}
