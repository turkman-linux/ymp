public static int clean_main (string[] args) {
    print (colorize (_ ("Clean: "), yellow) + _ ("package cache"));
    remove_all (get_storage () + "/packages");
    print (colorize (_ ("Clean: "), yellow) + _ ("repository index cache"));
    remove_all (get_storage () + "/index");
    print (colorize (_ ("Clean: "), yellow) + _ ("build directory"));
    remove_all (DESTDIR + "/tmp/ymp-build/");
    print (colorize (_ ("Clean: "), yellow) + _ ("quarantine"));
    quarantine_reset ();
    set_value ("OPERATION", "clean");
    directories_init();
    sysconf_main (args);
    return 0;
}

static void clean_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.names = {_ ("clean"), "clean", "cc"};
    op.callback.connect (clean_main);
    op.help.name = _ ("clean");
    op.help.description = _ ("Remove all caches.");
    add_operation (op);
}
