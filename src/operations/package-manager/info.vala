public int info_main(string[] args){
    if(get_bool("dependencies")){
        string[] required = resolve_dependencies(args);
        print(join(" ",required));
    }
    return 0;
}

void info_init(){
    var h = new helpmsg();
    h.name = "info";
    h.description = "Get informations from package manager databases.";
    h.add_parameter("--dependencies", "list required packages");
    add_operation(info_main,{"info","i"},h);
}
