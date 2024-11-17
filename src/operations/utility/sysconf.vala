private static int sysconf_main (string[] args) {
    if (!is_root () || get_bool ("no-sysconf")) {
        return 0;
    }
    save_env();
    clear_env();
    print (colorize (_ ("Running sysconf:"), yellow) + " " + get_value ("OPERATION"));
    setenv("PATH","/sbin:/bin:/usr/sbin:/usr/bin", 1);
    setenv ("OPERATION", get_value ("OPERATION"), 1);

    if (DESTDIR != "/") {
        run_args ( {"chroot", get_destdir (), "ldconfig"});
    }else {
        run ("ldconfig");
    }
    jobs j = new jobs();
    foreach (string hook in find (get_configdir () + "/sysconf.d")) {
        j.add((void*)run_sysconf, strdup(hook));
    }
    j.run();
    restore_env();
    return 0;
}

private static void run_sysconf(string fhook){
    string hook = fhook;
    if (isfile (hook)) {
        info (_ ("Run hook: %s").printf (sbasename (hook)));
        create_dir (get_storage () + "/sysconf/" + sbasename (hook));
        if (DESTDIR != "/") {
            hook=hook[DESTDIR.length:];
            if (0 != run_args ( {"chroot", get_destdir (), hook})) {
                warning (_ ("Failed to run sysconf: %s").printf (sbasename (hook)));
            }
        }else if (0 != run_args ({hook})) {
            warning (_ ("Failed to run sysconf: %s").printf (sbasename (hook)));
        }
    }
}

static void sysconf_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (sysconf_main);
    op.names = {_ ("sysconf"), "sc", "sysconf"};
    op.help.name = _ ("sysconf");
    op.help.description = _ ("Trigger sysconf operations.");
    add_operation (op);
}
