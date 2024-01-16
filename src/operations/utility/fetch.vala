private static int fetch_main (string[] args) {
    if (args.length < 1) {
        error_add (_ ("URL missing"));
        error (2);
    }

    if (args.length > 1) {
        fetch (args[0], args[1]);
    }else {
        string data = fetch_string (args[0]);
        if (data != null || data != "") {
            stdout.printf (data);
        }
    }
    return 0;
}

static void fetch_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (fetch_main);
    op.names = {_ ("fetch"), "fetch", "download", "dl"};
    op.help.name = _ ("fetch");
    op.help.minargs=1;
    op.help.description = _ ("Download files from network.");
    op.help.add_parameter ("--ignore-ssl", _ ("disable ssl check"));
    add_operation (op);
}
