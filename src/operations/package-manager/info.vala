public int info_main(string[] args){
    if(get_bool("deps")){
        bool ri = get_bool("reinstall");
        set_bool("reinstall",true);
        string[] required = resolve_dependencies(args);
        print(join(" ",required));
        set_bool("reinstall",ri);
    }else if(get_bool("revdeps")){
        bool ri = get_bool("reinstall");
        set_bool("reinstall",true);
        string[] required = resolve_reverse_dependencies(args);
        print(join(" ",required));
        set_bool("reinstall",ri);
    }else if(get_value("get") != ""){
        foreach(string name in args){
            package p = null;
            if(is_available_from_repository(name)){
                p = get_from_repository(name);
            }else if(is_installed_package(name)){
                p = get_installed_package(name);
            }
            if(p != null){
                print("%s: %s".printf(get_value("get"), p.get(get_value("get"))));
            }
        }
    }else{
        foreach(string name in args){
            package p = null;
            if(is_available_from_repository(name)){
                p = get_from_repository(name);
            }else if(is_installed_package(name)){
                p = get_installed_package(name);
            }
            if(p != null){
                if(p.is_source){
                    print("source:");
                }else{
                    print("package:");
                }
                print("  name: %s".printf(p.name));
                print("  version: %s".printf(p.version));
                print("  release: %d".printf(p.release));
                print("  depends: %s".printf(join(" ",p.dependencies)));
                print("  use_flags: %s".printf(join(" ",p.gets("use-flags"))));
                print("  groups: %s".printf(join(" ",p.gets("group"))));
                print("  is_installed: %s".printf(p.is_installed().to_string()));
                print("  remote_url: %s".printf(p.get_uri()));
             }
         }
    }
    return 0;
}

void info_init(){
    var h = new helpmsg();
    h.name = _("info");
    h.description = _("Get informations from package manager databases.");
    h.add_parameter("--deps", _("list required packages"));
    h.add_parameter("--revdeps", _("list packages required by package"));
    add_operation(info_main,{_("info"),"info","i"},h);
}
