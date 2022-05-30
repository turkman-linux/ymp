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
        read_values();
    }
    public void load_from_data(string data){
        yaml = new yamlfile();
        pkgarea = data;
        read_values();
    }
    
    private void read_values(){
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
            debug(@"Package data: $name");
            return yaml.get_value(pkgarea,name);
        }
        warning(@"Package information broken: $name");
        return "";
    }
    public bool is_installed(){
        return is_installed_package(name);
    }
}

public string[] list_installed_packages(){
    string[] pkgs = {};
    foreach(string fname in listdir(get_value("DESTDIR")+STORAGEDIR+"/metadata")){
        pkgs += split(fname,".")[0];
    }
    return pkgs;
}

private string get_metadata_path(string name){
    return get_value("DESTDIR")+STORAGEDIR+"/metadata/"+name+".yaml";
}

public package get_installed_packege(string name){
    package pkg = new package();
    string metadata = get_metadata_path(name);
    debug(pwd());
    debug("Loading package metadata from: "+metadata);
    pkg.load(metadata);
    return pkg;
}

public bool is_installed_package(string name){
    return isfile(get_metadata_path(name));
}

