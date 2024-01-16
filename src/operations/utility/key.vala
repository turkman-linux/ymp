private static int key_main (string[] args) {
    if(get_bool("add")){
        foreach(string arg in args){
            add_gpg_key(arg);
        }
    }
    return 0;
}

static void key_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (key_main);
    op.names = {_ ("key"), "key"};
    op.help.name = _ ("key");
    op.help.description = _ ("Gpg key operations.");
    op.help.add_parameter ("--add", _ ("add new gpg key"));
    add_operation (op);
}
