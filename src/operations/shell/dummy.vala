public int dummy_operation (string[] args) {
    return 0;
}
void dummy_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (dummy_operation);
    op.names = {_ ("init"), "init", ":", "#"};
    op.help.name = _ ("init");
    op.help.shell_only = true;
    op.help.description = _ ("Do nothing.");
    add_operation (op);
}
