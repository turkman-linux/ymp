private static int echo_main (string[] args) {
    print (join (" ", args));
    return 0;
}
void echo_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (echo_main);
    op.names = {_ ("echo"), "echo", "print"};
    op.help.name = _ ("echo");
    op.help.minargs = 1;
    op.help.description = _ ("Write a message to terminal.");
    op.help.shell_only = true;
    add_operation (op);
}
