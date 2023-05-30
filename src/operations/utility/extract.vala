public int extract_main (string[] args) {
    var tar = new archive ();
    tar.load (args[0]);
    if (get_bool ("list")) {
        foreach (string file in tar.list_files ()) {
            print (file);
        }
        return 0;
    }
    if (args.length > 1) {
        foreach (string file in args[1:]) {
            tar.extract (file);
        }
        return 0;
    }
    tar.extract_all ();
    return 0;
}

void extract_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (extract_main);
    op.names = {_ ("extract"), "extract", "x"};
    op.help.name = _ ("extract");
    op.help.minargs=1;
    op.help.description = _ ("Extract files from archive.");
    op.help.add_parameter ("--list", _ ("list archive files"));
    add_operation (op);
}
