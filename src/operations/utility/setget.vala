public int get_main(string[] args){
    if(args.length < 1){
        foreach(string name in list_values()){
            print(name+":"+get_value(name));
        }
        return 0;
    }
    var value = get_value(args[0]);
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

void setget_init(){
    var h1 = new helpmsg();
    var h2 = new helpmsg();

    h1.name = "get";
    h1.description = "Get variable from name";

    h2.name = "set";
    h2.description = "Set variable from name and value";

    add_operation(get_main,{"get"},h1);
    add_operation(set_main,{"set"},h2);
}
