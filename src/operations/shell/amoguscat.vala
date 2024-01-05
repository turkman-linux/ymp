private static int amoguscat_main (string[] args) {
    string data="";
    if (args[0] == "-" || args.length == 0) {
        string line = " ";
        while (line != "") {
            line = stdin.read_line ();
            data += line+"\n";
            print_with_amogus (data);
        }
    }else {
        data = readfile_raw (args[0]);
        print_with_amogus (data);
    }
    return 0;
}

void amoguscat_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (amoguscat_main);
    op.names = {_ ("amogus"), "amogus", "sus"};
    op.help.name = _ ("amogus");
    op.help.minargs=1;
    op.help.shell_only = true;
    op.help.description = _ ("When message is sus.");
    op.help.add_parameter ("-", _ ("write from stdin"));
    add_operation (op);
}
