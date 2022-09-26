public int info_main(string[] args){
    if(get_bool("required-depends")){
        string[] required = resolve_dependencies(args);
        print(join(" ",required));
    }
    return 0;
}

void info_init(){
    add_operation(info_main,{"info","i"},"Get information.");
}
