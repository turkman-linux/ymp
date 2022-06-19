public int install_main(string[] args){
    string[] pkgs = resolve_dependencies(args);
    if(get_bool("ignore-dependency")){
        pkgs = args;
    }
    package[] pkg_obj = {};
    create_dir(get_storage()+"/packages/");
create_dir(get_storage()+"/metadata/");
create_dir(get_storage()+"/files/");
    // Download package files from repository
    foreach(string pkg in pkgs){
        if(isfile(pkg)){
            package p = new package();
            p.load_from_archive(pkg);
            pkg_obj += p;
        }else{
            package p = get_package_from_repository(pkg);
            p.download();
            pkg_obj += p;
        }
    }
    error(2);
    //If download-only finish operation
    if(get_bool("download-only")){
	    return 0;	
	}
quarantine_reset();
	foreach(package p in pkg_obj){
	    info("Extracting: "+p.name);
	    p.extract();
	}
	quarantine_validate_files();
	calculate_leftover(pkg_obj);
	quarantine_install();
    return 0;
}
public string[] calculate_leftover(package[] pkgs){
    foreach(package p in pkgs){
        if(is_installed_package(p.name)){
             package pi = get_installed_package(p.name);
             print(pi.name);
        }
    }
    return {};
}
public void install_init(){
    add_operation(install_main,{"install","it"});
}
