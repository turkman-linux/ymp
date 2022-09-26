public int install_main(string[] args){
    string[] pkgs = resolve_dependencies(args);
    quarantine_reset();
    package[] pkg_obj = {};
    foreach(string name in pkgs){
        package pkg = install_single(name);
        if(pkg == null){
            error(1);
        }else{
            pkg_obj += pkg;
        }
    }
    info("Quarantine validation");
    quarantine_validate_files();
    error(1);
    info("Quarantine installation");
    quarantine_install();
    error(1);
    info("Clear leftovers");
    foreach(string file in calculate_leftover(pkg_obj)){
        remove_file(DESTDIR+"/"+file);
    }
    sysconf_main(args);
    error(1);
    return 0;
}
public package install_single(string pkg){
    package p = null;
    // Download package files from repository
    if(isfile(pkg)){
        info("Installing from package file:" + pkg);
        p = new package();
        p.load_from_archive(pkg);
    }else{
        info("Installing from repository:" + pkg);
        p = get_package_from_repository(pkg);
        p.download();
    }
    error(2);
    //If download-only finish operation
    info("Installing: "+p.name);
    if(p.is_source){
        p.build();
        quarantine_validate_files();
        error(1);
        quarantine_install();
    }else{
        p.extract();
    }
    return p;
}
public string[] calculate_leftover(package[] pkgs){
    string[] installed_files = {};
    string[] new_files = {};
    string[] leftover = {};
    // Fetch installed and new files list
    foreach(package p in pkgs){
        if(is_installed_package(p.name) && !p.is_source ){
             //new files list
             foreach(string file in p.list_files()){
                 if(file.length > 41){
                     new_files += file[41:];
                 }
             }
             // installed files
             package pi = get_installed_package(p.name);
             foreach(string file in pi.list_files()){
                 if(file.length > 41){
                     installed_files += file[41:];
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
void install_init(){
    add_operation(install_main,{"install","it"},"Install package");
}
