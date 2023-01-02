public int install_main(string[] args){
    if(!is_root()){
        error_add(_("You must be root!"));
        error(1);
    }
    if(!get_bool("no-emerge") && usr_is_merged()){
        error_add(_("Install (from source) operation with usrmerge is not allowed!"));
        error(31);
    }
    single_instance();
    var a = new array();
    a.adds(resolve_dependencies(args));
    if(get_bool("upgrade")){
        string[] up_pkgs = get_upgradable_packages();
        a.adds(resolve_dependencies(up_pkgs));
    }
    string[] pkgs = a.get();
    info(_("Resolve dependency done: %s").printf(join(" ",pkgs)));
    quarantine_reset();
    package[] pkg_obj = {};
    foreach(string name in pkgs){
        if(is_available_from_repository(name)){
            package p = get_from_repository(name);
            p.download_only();
        }
    }
    foreach(string name in pkgs){
        package pkg = install_single(name);
        if(pkg == null){
            error(1);
        }else{
            pkg_obj += pkg;
        }
    }
    string[] leftovers = calculate_leftover(pkg_obj);
    if(!quarantine_validate_files()){
        error_add(_("Quarantine validation failed"));
        quarantine_reset();
    }
    error(1);
    quarantine_install();
    quarantine_reset();
    error(1);
    print(colorize(_("Clear leftovers"),yellow));
    foreach(string file in leftovers){
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
        info(_("Installing from package file: %s").printf(pkg));
        p = new package();
        p.load_from_archive(srealpath(pkg));
    }else{
        info(_("Installing from repository: %s").printf(pkg));
        p = get_from_repository(pkg);
        p.download();
    }
    if (p.get("arch") != getArch()){
        error_add(_("Package architecture is not supported"));
    }
    error(2);
    print(colorize(_("Installing:"),yellow)+" "+p.name);
    if(p.is_source || get_bool("sync-single")){
        p.build();
        if(!quarantine_validate_files()){
            error_add(_("Quarantine validation failed"));
            quarantine_reset();
        }
        error(1);
        quarantine_install();
        quarantine_reset();
    }else{
        p.extract();
    }
    return p;
}
public string[] calculate_leftover(package[] pkgs){
    print(colorize(_("Calculating leftovers"),yellow));
    var files = new array();
    // Fetch installed and new files list
    foreach(package p in pkgs){
        if(is_installed_package(p.name) && !p.is_source ){
             // installed files
             package pi = get_installed_package(p.name);
             foreach(string file in pi.list_files()){
                 if(file.length > 41){
                     files.add(file[41:]);
                 }
             }
             // installed symlinks
             foreach(string link in pi.list_links()){
                 files.add(ssplit(link," ")[0]);
             }
             // new files
             foreach(string file in ssplit(readfile(get_storage()+"/quarantine/files/"+p.name),"\n")){
                 if(file.length > 41){
                     files.remove(file[41:]);
                 }
             }
             //new symlinks
             foreach(string link in ssplit(readfile(get_storage()+"/quarantine/links/"+p.name),"\n")){
                 files.remove(ssplit(link," ")[0]);
             }
        }
    }
    return files.get();
}
void install_init(){
    var h = new helpmsg();
    h.name = _("install");
    h.description = _("Install package from source or package file or repository");
    h.add_parameter("--ignore-dependency", _("disable dependency check"));
    h.add_parameter("--ignore-satisfied", _("ignore not satisfied packages"));
    h.add_parameter("--sync-single", _("sync quarantine after every package installation"));
    h.add_parameter("--reinstall", _("reinstall if already installed"));
    h.add_parameter("--upgrade", _("upgrade all packages"));
    h.add_parameter("--no-emerge", _("use binary packages"));
    add_operation(install_main,{_("install"),"install","it","add"},h);
}
