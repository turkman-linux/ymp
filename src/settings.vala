
private string DESTDIR;
private string CONFIG;
public class inaryconfig {
    public string jobs;
    public string debug;
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
    return config;
}

public void set_destdir(string path){
    DESTDIR=path;
}

public void set_config(string path){
    CONFIG=path;
}
