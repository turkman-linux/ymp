
//DOC: ## Settings functions
//DOC: inary configuration functions
private string CONFIG;
private string DESTDIR;

private void settings_init(){
    inifile ini = new inifile();
    if(DESTDIR == null){
        DESTDIR = "/";
    }
    if (CONFIG == null){
        CONFIG = DESTDIR+"/"+CONFIGDIR+"/inary.conf";
    }
    set_value_readonly("destdir",DESTDIR);
    set_value_readonly("config",CONFIG);
    if(VERSION != null){
        set_value_readonly("version",VERSION);
    }
    if(isfile(CONFIG)){
        ini.load(CONFIG);
        foreach(string section in ini.get_sections()){
            foreach(string variable in ini.get_variables("inary")){
                if(section == "inary"){
                    set_value(variable,ini.get("inary",variable));
                }else{
                    set_value(section+":"+variable,ini.get(section,variable));
                }
            }
        }
    }else{
        warning("Config file not exists: "+CONFIG);
    }
    clear_env();
}

//DOC: `void set_destdir(string rootfs):`
//DOC: change distdir
public void set_destdir(string rootfs){
    DESTDIR=rootfs;
    settings_init();
}

//DOC: `string get_storage():`
//DOC: get inary storage directory. (default: /var/lib/inary)
public string get_storage(){
    return DESTDIR+"/"+STORAGEDIR;
}

private string get_metadata_path(string name){
    return get_storage()+"/metadata/"+name+".yaml";
}

//DOC: `void set_config(string path):`
//DOC: change inary config file (default /etc/inary.conf)
public void set_config(string path){
    CONFIG=path;
    settings_init();
}
private void parse_args(string[] args){
    foreach(string arg in args){
        arg = arg.down();
        if(startswith(arg,"--")){
            if(arg.contains("=")){
                if(ssplit(arg[2:],"=")[0] == "destdir"){
                    DESTDIR = ssplit(arg[2:],"=")[1];
                }else{
                    set_value(ssplit(arg[2:],"=")[0],ssplit(arg[2:],"=")[1]);
                }
            }else{
                set_bool(arg[2:],true);
            }
        }
    }
    if(get_env("NO_COLOR") != null){
        set_bool("no-color",true);
    }
}
