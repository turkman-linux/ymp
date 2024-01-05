private static int bootstrap_main (string[] args) {
    if (!is_root ()) {
        error_add (_ ("You must be root!"));
    }
    string repo=get_value ("mirror");
    string rootfs=get_destdir ();
    if (repo == "") {
        error_add (_ ("Mirror is not defined. Please use --mirror ."));
    }if (DESTDIR == "/") {
        error_add (_ ("Destdir is not defined. Please use --destdir ."));
    }
    if (isfile (DESTDIR + "/etc/os-release")) {
        error_add (_ ("Target rootfs already exists: %s").printf (DESTDIR));
    }
    error (2);
    info (colorize (_ ("Creating bootstrap."), blue));
    string[] basedir = {"dev", "sys", "proc", "run"};
    string[] base_packages = {"busybox", "base-files", "glibc"};
    foreach (string dir in basedir) {
        create_dir (rootfs + "/" + dir);
    }
    GLib.FileUtils.chmod (rootfs + "/tmp", 0777);
    bool sysconf = get_bool ("no-sysconf");
    set_bool ("no-sysconf", true);
    copy_file ("/etc/resolv.conf", rootfs + "/etc/resolv.conf");
    writefile (rootfs + "/" + STORAGEDIR + "/sources.list", repo + "\n");
    writefile (rootfs + "/" + STORAGEDIR + "/restricted.list", "/data/user\n");
    update_main (args);
    install_main (base_packages);
    foreach (string package in base_packages) {
        string hook = get_configdir () + "/sysconf.d/";
        create_dir (get_destdir () + "/var/lib/ymp/sysconf/" + package);
        hook = hook[get_destdir ().length:];
        run_args ( {"chroot", get_destdir (), hook + package});
    }
    install_main (args);
    set_bool ("no-sysconf", sysconf);
    sysconf_main (args);
    return 0;
}

void bootstrap_init () {
    operation op = new operation ();
    op.callback.connect (bootstrap_main);
    op.names = {_ ("bootstrap"), "bootstrap", "bst"};
    op.help = new helpmsg ();
    op.help.name = _ ("bootstrap");
    op.help.description = _ ("Create new rootfs filesystem.");
    op.help.add_parameter ("--mirror", _ ("bootstrap mirror uri"));
    op.help.add_parameter ("--no-emerge", _ ("use binary packages"));
    add_operation (op);
}
