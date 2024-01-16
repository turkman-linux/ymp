private static int sysconf_main (string[] args) {
    if (!is_root () || get_bool ("no-sysconf")) {
        return 0;
    }
    if (get_value ("OPERATION") != "install" && get_value ("OPERATION") != "remove") {
        set_env ("OPERATION", get_value ("OPERATION"));
    }
    if (DESTDIR != "/") {
        run_args ( {"chroot", get_destdir (), "ldconfig"});
    }else {
        run ("ldconfig");
    }
    foreach (string hook in find (get_configdir () + "/sysconf.d")) {
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
    set_env ("OPERATION", "");
    return 0;
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
