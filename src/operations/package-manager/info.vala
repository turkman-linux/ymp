public int info_main(string[] args){
    if(get_bool("deps")){
        bool ri = get_bool("reinstall");
        set_bool("reinstall",true);
        string[] required = resolve_dependencies(args);
        print(join(" ",required));
        set_bool("reinstall",ri);
    }
    return 0;
}

void info_init(){
    var h = new helpmsg();
    h.name = "info";
    h.description = "Get informations from package manager databases.";
    h.add_parameter("--deps", "list required packages");
    add_operation(info_main,{"info","i"},h);
}
