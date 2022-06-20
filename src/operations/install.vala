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
	    if(get_bool("reinstall")){
	        p.extract();
	    }else if(is_installed_package(p.name)){
	        package pi = get_installed_package(p.name);
	        if(pi.release < p.release){
	            p.extract();
	        }
	    }else{
	        p.extract();
	    }
	}
	quarantine_validate_files();
	string[] leftovers = calculate_leftover(pkg_obj);
	quarantine_install();
	foreach(string file in leftovers){
	    remove_file(file);
	}
    return 0;
}
public string[] calculate_leftover(package[] pkgs){
    string[] installed_files = {};
    string[] new_files = {};
    string[] leftover = {};
    // Fetch installed and new files list
    foreach(package p in pkgs){
        if(is_installed_package(p.name)){
             //new files list
             foreach(string file in p.list_files()){
                 if(file.length > 40){
                     new_files += file[40:];
                 }
             }
             // installed files
             package pi = get_installed_package(p.name);
             foreach(string file in pi.list_files()){
                 if(file.length > 40){
                     installed_files += file[40:];
                 }
             }
        }
    }
    // Calculate leftover files
    foreach(string file in installed_files){
        if(!(file in new_files)){
            leftover += file;
            debug("Leftover file detected: "+file);
        }
    }
    return leftover;
}
public void install_init(){
    add_operation(install_main,{"install","it"});
}
