public string CONFIG;
public string DESTDIR;

public void settings_init(){
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
        string[] sections = {"jobs", "no_color"};
        foreach(string section in sections){
            set_value(section,ini.get("build",section));
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

public void set_config(string path){
    CONFIG=path;
}
public void parse_args(string[] args){
    foreach(string arg in args){
        switch(arg){
            case "--ask":
                set_value("interactive","true");
                break;
            case "--no-color":
                set_value("no_color","true");
                break;
        }
    }
}
