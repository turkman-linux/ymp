private static int key_main (string[] args) {
    if(get_bool("add")){
        if (get_value("name") == ""){
            error_add (_ ("name not defined."));
            return 1;
        }
        add_gpg_key(args[0], get_value("name"));
    }else if(get_bool("remove")){
        remove_file(get_storage()+"/gpg/"+args[0]+".gpg");
    }else if(get_bool("list")){
        foreach(string key in listdir(get_storage()+"/gpg/")){
            if(endswith(key,".gpg")){
                print(key[:-4]);
            }else{
                remove_all(key);
            }
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
    op.help.add_parameter ("--remove", _ ("remove gpg key"));
    op.help.add_parameter ("--list", _ ("list gpg keys"));
    op.help.add_parameter (colorize (_ ("Add options"), magenta), "");
    op.help.add_parameter ("--name", _ ("key name"));
    add_operation (op);
}
