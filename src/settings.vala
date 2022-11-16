
//DOC: ## Settings functions
//DOC: ymp configuration functions
private string CONFIG;
private string DESTDIR;

private void settings_init(){
    var yaml = new yamlfile();
    if(DESTDIR == null){
        DESTDIR = "/";
    }
    if (CONFIGDIR == null){
        CONFIGDIR = "/etc/";
    }
    if (CONFIG == null){
        CONFIG = srealpath(DESTDIR+"/"+CONFIGDIR+"/ymp.conf");
    }
    set_value_readonly("destdir",DESTDIR);
    set_value_readonly("config",CONFIG);
    if(VERSION != null){
        set_value_readonly("version",VERSION);
    }
    string area = "";
    string value = "";
    if(isfile(CONFIG)){
        yaml.load(CONFIG);
        foreach(string section in yaml.get_area_names(yaml.data)){
            area = yaml.get_area(yaml.data,section);
            foreach(string variable in yaml.get_area_names(area)){
                value = yaml.get_value(area,variable);
                if(section == "ymp"){
                    set_value_readonly(variable,value);
                }else{
                    set_value_readonly(section+":"+variable,value);
                }
            }
        }
    }else{
        warning("Config file not exists: "+CONFIG);
    }
    if(get_env("USE") != null){
        set_value_readonly("USE",get_env("USE"));
    }else{
        area = yaml.get_area(yaml.data,"ymp");
        set_value_readonly("USE",yaml.get_value(area,"use"));
    }
    #if DEBUG
    set_env("G_MESSAGES_DEBUG", "all");
    set_env("G_DEBUG","fatal_warnings");
    #endif
}

//DOC: `void set_destdir(string rootfs):`
//DOC: change distdir
public void set_destdir(string rootfs){
    DESTDIR=srealpath(rootfs);
    info("Destdir changed:"+DESTDIR);
    settings_init();
}

//DOC: `string get_storage():`
//DOC: get ymp storage directory. (default: /var/lib/ymp)
public string get_storage(){
    return srealpath(DESTDIR+"/"+STORAGEDIR);
}

//DOC: `string get_configdir():`
//DOC: get ymp storage directory. (default: /etc/)
public string get_configdir(){
    return srealpath(DESTDIR+"/"+CONFIGDIR);
}

public string get_destdir(){
    if(DESTDIR == null){
        DESTDIR = "/";
    }
    return DESTDIR;
}

//DOC: `string get_storage():`
//DOC: get ymp storage directory. (default: /var/lib/ymp)
public string get_build_dir(){
    return srealpath(DESTDIR+"/tmp/ymp-build")+"/";
}

private string get_metadata_path(string name){
    return get_storage()+"/metadata/"+name+".yaml";
}

//DOC: `void set_config(string path):`
//DOC: change ymp config file (default /etc/ymp.conf)
public void set_config(string path){
    CONFIG=srealpath(path);
    settings_init();
}
private void parse_args(string[] args){
    foreach(string arg in args){
        if(arg == "--"){
            return;
        }
        var argname = arg[2:];
        if(startswith(arg,"--")){
            if(argname == "allow-oem"){
                    set_value_readonly("allow-oem","true");
            }else if(arg.contains("=")){
                var name = ssplit(argname,"=")[0];
                var value = argname[name.length+1:];
                if(name == "use"){
                    set_value_readonly(name,value);
                }else if(name == "destdir"){
                    set_destdir(value);
                }else if(name == "config"){
                    set_config(value);
                }else{
                    set_value(name,value);
                }
            }else{
                set_bool(argname,true);
            }
        }
    }
    if(get_env("NO_COLOR") != null){
        set_bool("no-color",true);
    }
}
