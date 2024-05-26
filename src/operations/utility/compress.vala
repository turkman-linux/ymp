private static int compress_main (string[] args) {
    var tar = new archive ();
    tar.load (args[0]);
    tar.set_type (get_value ("type"), get_value ("algorithm"));
    if (args.length > 1) {
        foreach (string file in args[1:]) {
            if (isdir (file)) {
                foreach (string path in find (file)) {
                    tar.add (path);
                }
            }else {
                tar.add (file);
            }
        }
    }
    tar.create ();
    return 0;
}

static void compress_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (compress_main);
    op.names = {_ ("compress"), "compress", "prs"};
    op.help.name = _ ("compress");
    op.help.minargs=1;
    op.help.description = _ ("Compress file or directories.");
    op.help.add_parameter ("--algorithm", _ ("compress algorithm"));
    op.help.add_parameter ("--type", _ ("archive format"));
    add_operation (op);
}
