private static int exit_main (string[] args) {
    int status = 0;
    if (args.length > 0) {
        status = int.parse (args[0]);
    }
    exit (status);
    return 0;
}
void exit_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (exit_main);
    op.names = {_ ("exit"), "exit", "bye"};
    op.help.name = _ ("exit");
    op.help.description = _ ("Exit ymp");
    op.help.shell_only = true;
    add_operation (op);
}
