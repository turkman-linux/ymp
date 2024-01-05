private static int clear_main (string[] args) {
    stdout.printf ("\x1b" + "c");
    return 0;
}
void clear_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (clear_main);
    op.names = {_ ("clear"), "clear"};
    op.help.name = _ ("clear");
    op.help.description = _ ("Clear terminal screen.");
    op.help.shell_only = true;
    add_operation (op);
}
