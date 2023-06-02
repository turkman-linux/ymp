public int title_main (string[] args) {
    string data="";
    foreach (string arg in args) {
        data += arg + " ";
    }
    set_terminal_title (data[0:data.length - 1]);
    return 0;
}
void title_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (title_main);
    op.names = {_ ("title"), "title"} ;
    op.help.name = _ ("title");
    op.help.minargs=1;
    op.help.shell_only = true;
    op.help.description = _ ("Set terminal title");
    add_operation (op);
}
