public int get_main(string[] args){
    if(args.length < 1){
        foreach(string name in list_values()){
            print(name+":"+get_value(name));
        }
        return 0;
    }
    var value = get_value(args[0]);
    if(value == ""){
        return 1;
    }
    print(value);
    return 0;
}

public int set_main(string[] args){
    if(args.length < 2){
        return 1;
    }
    set_value(args[0],args[1]);
    return 0;
}

public int read_main(string[] args){
    if(args.length < 1){
        return 1;
    }
    set_value(args[0],stdin.read_line());
    return 0;
}

public int equal_main(string[] args){
    if(args.length < 2){
        return 1;
    }
    if (args[0] == args[1]){
        return 0;
    }
    return 1;
}

public int match_main(string[] args){
    if(args.length < 2){
        return 1;
    }
    if(Regex.match_simple(args[0],args[1])){
        return 0;
    }
    return 1;
}

public int cd_main(string[] args){
    foreach(string arg in args){
        cd(arg);
    }
    return 0;
}

void setget_init(){
    var h1 = new helpmsg();
    var h2 = new helpmsg();
    var h3 = new helpmsg();
    var h4 = new helpmsg();
    var h5 = new helpmsg();
    var h6 = new helpmsg();

    h1.name = _("get");
    h1.shell_only = true;
    h1.description = _("Get variable from name.");

    h2.name = _("set");
    h2.minargs=2;
    h2.shell_only = true;
    h2.description = _("Set variable from name and value.");

    h3.name = _("equal");
    h3.minargs=2;
    h3.shell_only = true;
    h3.description = _("Compare arguments equality.");
    
    h4.name = _("read");
    h4.minargs=1;
    h4.shell_only = true;
    h4.description = _("Read value from terminal.");

    h5.name = _("match");
    h5.minargs=2;
    h5.shell_only = true;
    h5.description = _("Match arguments regex.");

    h6.name = _("cd");
    h6.shell_only = true;
    h6.description = _("Change directory.");

    add_operation(get_main,{_("get"),"get"},h1);
    add_operation(set_main,{_("set"),"set"},h2);
    add_operation(equal_main,{_("equal"),"equal","eq"},h3);
    add_operation(read_main,{_("read"),"read","input"},h4);
    add_operation(match_main,{_("match"),"match","regex"},h5);
    add_operation(cd_main,{_("cd"),"cd"},h6);
}
