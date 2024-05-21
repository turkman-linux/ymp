private static int install_main (string[] args) {
    backup_env();
    clear_env();
    file_cache_reset();
    set_env("PATH","/sbin:/bin:/usr/sbin:/usr/bin");

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
    package[] pkg_obj = {};
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
    foreach (string name in pkgs) {
        package pkg = install_single (name);
        if (pkg == null) {
            error (1);
        }else {
            pkg_obj += pkg;
        }
    }
    string[] leftovers = calculate_leftover (pkg_obj);
    if (!quarantine_validate_files ()) {
        error_add (_ ("Quarantine validation failed."));
        quarantine_reset ();
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
private static package install_single (string pkg) {
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
    print (colorize (_ ("Installing: %s"), yellow).printf (p.name));
    if (p.is_source || get_bool ("sync-single")) {
        p.build ();
        if (!quarantine_validate_files ()) {
            error_add (_ ("Quarantine validation failed."));
            quarantine_reset ();
        }
        error (1);
        quarantine_install ();
        quarantine_reset ();
        sysconf_main ( {});
    }else {
        p.extract ();
    }
    return p;
}
private static string[] calculate_leftover (package[] pkgs) {
    print (colorize (_ ("Calculating leftovers"), yellow));
    var files = new array ();
    // Fetch installed and new files list
    foreach (package p in pkgs) {
        if (is_installed_package (p.name) && !p.is_source ) {
             // installed files
             package pi = get_installed_package (p.name);
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
             foreach (string file in ssplit (readfile_cached (get_storage () + "/quarantine/files/" + p.name), "\n")) {
                 if (file.length > 41) {
                     files.remove (file[41:]);
                 }
             }
             //new symlinks
             foreach (string link in ssplit (readfile_cached (get_storage () + "/quarantine/links/" + p.name), "\n")) {
                 files.remove (ssplit (link, " ")[0]);
             }
        }
    }
    return files.get ();
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
