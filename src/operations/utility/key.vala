public int key_main (string[] args) {
    if(get_bool("add")){
        foreach(string arg in args){
            add_gpg_key(arg);
        }
    }
    return 0;
}
void key_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (key_main);
    op.names = {_ ("key"), "key"};
    op.help.name = _ ("key");
    op.help.description = _ ("Gpg key operations.");
    add_operation (op);
}
