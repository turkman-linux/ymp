
private string DESTDIR;
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
    string path = DESTDIR+CONFIGDIR+"/inary.conf";
    ini.load(path);
    config.jobs = ini.get("build","jobs");
    config.debug = ini.get("build","debug");
    return config;
}
public void set_destdir(string path){
    DESTDIR=path;
}
