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
    add_operation(get_main,{"get"});
    add_operation(set_main,{"set"});
}
