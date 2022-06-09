public int install_main(string[] args){
    string[] pkgs = resolve_dependencies(args);
    string[] pkg_uris = {};
    foreach(string pkg in pkgs){
        package p = get_package_from_repository(pkg);
        pkg_uris += p.get_uri();
    }
    create_dir(get_storage()+"/packages/");
    foreach(string uri in pkg_uris){
        if(!fetch(uri,get_storage()+"/packages/"+sbasename(uri))){
            error_add("failed to fetch package: "+uri);
        }
    }
    error(2);
    return 0;
}
public void install_init(){
    add_operation(install_main,{"install","it"});
}
