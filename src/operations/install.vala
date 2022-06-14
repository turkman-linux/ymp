public int install_main(string[] args){
    string[] pkgs = resolve_dependencies(args);
    package[] pkg_obj = {};
    create_dir(get_storage()+"/packages/");
    // Download package files from repository
    foreach(string pkg in pkgs){
        package p = get_package_from_repository(pkg);
        p.download();
        pkg_obj += p;
    }
    error(2);
    //If download-only finish operation
    if(get_bool("download-only")){
	    return 0;	
	}
	foreach(package p in pkg_obj){
	    p.extract();
	}
    return 0;
}
public void install_init(){
    add_operation(install_main,{"install","it"});
}
