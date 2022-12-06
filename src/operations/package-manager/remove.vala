public int remove_main(string[] args){
    if(!is_root()){
        error_add(_("You must be root!"));
        error(1);
    }
    single_instance();
    string[] pkgs = {};
    if(get_bool("ignore-dependency")){
        pkgs = args;
    }else{
        pkgs = resolve_reverse_dependencies(args);
    }
    foreach(string pkg in pkgs){
        package p = get_installed_package(pkg);
        remove_single(p);
    }
    sysconf_main(args);
    return 0;
}

public int remove_single(package p){
    print(colorize(_("Removing:"),yellow)+" "+p.name);
    foreach(string file in p.list_files()){
        if(file.length > 41){
            file=file[41:];
            remove_file(DESTDIR+"/"+file);
        }
    }foreach(string file in p.list_links()){
        if(file.length > 3){
            file=ssplit(file," ")[0];
            remove_file(DESTDIR+"/"+file);
        }
    }
    remove_file(get_storage()+"/metadata/"+p.name+".yaml");
    remove_file(get_storage()+"/files/"+p.name);
    remove_file(get_storage()+"/links/"+p.name);
    if(isdir(get_storage()+"/sysconf/"+p.name)){
        remove_all(get_storage()+"/sysconf/"+p.name);
    }
    return 0;
}

void remove_init(){
    var h = new helpmsg();
    h.name = _("remove");
    h.minargs=1;
    h.description = _("Remove package from package name");
    h.add_parameter("--ignore-dependency", _("disable dependency check"));
    add_operation(remove_main,{_("remove"),"remove","rm"},h);
}
