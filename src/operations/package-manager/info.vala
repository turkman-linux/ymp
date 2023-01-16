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
            if(is_available_from_repository(name)){
                package p = get_from_repository(name);
                print("%s: %s".printf(get_value("get"), p.get(get_value("get"))));
            }
        }
    }else{
        foreach(string name in args){
            if(is_available_from_repository(name)){
                package p = get_from_repository(name);
                if(p.is_source){
                    print("source:");
                }else{
                    print("package:");
                }
                print("  "+_("name: %s").printf(p.name));
                print("  "+_("version: %s").printf(p.version));
                print("  "+_("release: %d").printf(p.release));
                print("  "+_("depends: %s").printf(join(" ",p.dependencies)));
                print("  "+_("remote_url: %s").printf(p.get_uri()));
                print("  "+_("is_installed: %s").printf(p.is_installed().to_string()));
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
