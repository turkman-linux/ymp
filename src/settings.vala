
//DOC: ## Settings functions
//DOC: inary configuration functions;

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

//DOC: `void set_destdir(string rootfs):`;
//DOC: change distdir ;
public void set_destdir(string rootfs){
    DESTDIR=rootfs;
    set_value("DESTDIR",rootfs);
    settings_init();
}

//DOC: `string get_storage():`;
//DOC: get inary storage directory. (default: /var/lib/inary);
public string get_storage(){
    return get_value("DESTDIR")+STORAGEDIR;
}

//DOC: `void set_config(string path):`;
//DOC: change inary config file (default /etc/inary.conf);
public void set_config(string path){
    CONFIG=path;
    settings_init();
}
private void parse_args(string[] args){
    foreach(string arg in args){
        switch(arg){
            case "--ask":
                set_bool("interactive",true);
                break;
            case "--no-color":
                set_bool("no_color",true);
                break;
            case "--verbose":
                set_bool("verbose",true);
                break;
            case "--debug":
                set_bool("debug",true);
                break;
        }
        if(startswith(arg,"-D")){
            set_value("DESTDIR",arg[2:]);
        }
    }
    if(get_env("NO_COLOR") != null){
        set_bool("no_color",true);
    }
}
