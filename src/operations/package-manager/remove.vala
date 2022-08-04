public int remove_main(string[] args){
    string[] pkgs = resolve_reverse_dependencies(args);
    if(get_bool("ignore-dependency")){
        pkgs = args;
    }
    foreach(string pkg in pkgs){
        package p = get_installed_package(pkg);
        print(p.name);
        remove_single(p);
    }
    sysconf_main(null);
    return 0;
}

public int remove_single(package p){
    foreach(string file in p.list_files()){
        if(file.length > 41){
            file=file[41:];
            remove_file(file);
        }
    }
    remove_file(get_storage()+"/metadata/"+p.name+".yaml");
    remove_file(get_storage()+"/files/"+p.name);
    return 0;
}

void remove_init(){
    add_operation(remove_main,{"remove","rm"});
}
