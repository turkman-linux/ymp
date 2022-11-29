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

void setget_init(){
    var h1 = new helpmsg();
    var h2 = new helpmsg();
    var h3 = new helpmsg();
    var h4 = new helpmsg();

    h1.name = "get";
    h1.description = "Get variable from name";

    h2.name = "set";
    h2.minargs=2;
    h2.description = "Set variable from name and value";

    h3.name = "equal";
    h3.minargs=2;
    h3.description = "Compare arguments equality";
    
    h4.name = "read";
    h4.minargs=1;
    h4.description = "Read value from terminal";

    add_operation(get_main,{"get"},h1);
    add_operation(set_main,{"set"},h2);
    add_operation(equal_main,{"equal","eq"},h3);
    add_operation(read_main,{"read","input"},h4);
}
