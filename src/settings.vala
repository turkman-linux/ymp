public string CONFIG;
public string DESTDIR;

private void settings_init(){
    ctx_init();
    inifile ini = new inifile();
    if(DESTDIR == null){
        DESTDIR = "/";
    }
    if (CONFIG == null){
        CONFIG = DESTDIR+"/"+CONFIGDIR+"/inary.conf";
    }
    if(isfile(CONFIG)){
        ini.load(CONFIG);
        foreach(string section in ini.get_variables("inary")){
            set_value(section,ini.get("inary",section));
        }
    }else{
        warning("Config file not exists:"+"\n"+CONFIG);
    }
    clear_env();
}


public void set_destdir(string rootfs){
    DESTDIR=rootfs;
    set_value("DESTDIR",rootfs);
    settings_init();
}

public string get_storage(){
    return get_value("DESTDIR")+STORAGEDIR;
}

public void set_config(string path){
    CONFIG=path;
    settings_init();
}
private void parse_args(string[] args){
    foreach(string arg in args){
        switch(arg){
            case "--ask":
                set_value("interactive","true");
                break;
            case "--no-color":
                set_value("no_color","true");
                break;
        }
        if(startswith(arg,"-D")){
            set_value("DESTDIR",arg[2:]);
        }
    }
}
