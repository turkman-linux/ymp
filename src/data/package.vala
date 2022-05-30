public class package {
    private yamlfile yaml;
    public string name;
    public string version;
    public string[] dependencies;
    public string[] provides;
    private string pkgarea;
    
    public void load(string metadata){
        yaml = new yamlfile();

        yaml.load(metadata);
        pkgarea = yaml.get("inary.package");
        name = get("name");
        version = get("version");
        dependencies = gets("dependencies");
        provides = gets("provides");
    }
    
    public string[] gets(string name){
        if (yaml.has_area(pkgarea,name)){
            return yaml.get_array(pkgarea,name);
        }
        return {};
    }
    
    public string get(string name){
        if (yaml.has_area(pkgarea,name)){
            return yaml.get_value(pkgarea,name);
        }
        error_add(@"Package information broken: $name");
        return "";
    }
}

public string[] list_installed_packages(){
    string[] pkgs = {};
    foreach(string fname in listdir(DESTDIR+STORAGEDIR+"/metadata")){
        pkgs += split(fname,".")[0];
    }
    return pkgs;
}
private string get_metadata_path(string name){
    return DESTDIR+STORAGEDIR+"/metadata/"+name+".yaml";
}

public package get_installed_packege(string name){
    package pkg = new package();
    string metadata = get_metadata_path(name);
    debug(pwd());
    debug("Loading package metadata from: "+metadata);
    pkg.load(metadata);
    return pkg;
}
public bool is_installed(string name){
    return isfile(get_metadata_path(name));
}
