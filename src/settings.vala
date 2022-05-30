
private string DESTDIR;
private string CONFIG;
public class inaryconfig {
    public string jobs;
    public string debug;
    public bool interactive;
    public bool colorize;
    public bool shellmode;
}

public inaryconfig settings_init(){
    
    inifile ini = new inifile();
    inaryconfig config = new inaryconfig();
    if (DESTDIR == null){
        DESTDIR="/";
    }
    if (CONFIG == null){
        CONFIG = DESTDIR+CONFIGDIR+"/inary.conf";
    }
    ini.load(CONFIG);
    config.jobs = ini.get("build","jobs");
    config.debug = ini.get("build","debug");
    config.interactive = (ini.get("inary","interactive") == "true");
    config.colorize = (ini.get("inary","colorize") != "false");
    config.shellmode = (ini.get("inary","shellmode") == "true");
    return config;
}

public void set_destdir(string path){
    DESTDIR=path;
}

public void set_config(string path){
    CONFIG=path;
}
public void parse_args(string[] args){
    foreach(string arg in args){
        switch(arg){
            case "--ask":
                config.interactive = true;
                break;
            case "--no-color":
                config.colorize = false;
                break;
        }
    }
}
