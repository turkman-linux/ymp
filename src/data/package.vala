public class package {
    private yamlfile yaml;
    public string name;
    public string version;
    
    public void load(string metadata){
        yaml = new yamlfile();

        yaml.load(metadata);
        var pkgarea = yaml.get("inary.package");
        name = yaml.get_value(pkgarea,"name");
        version = yaml.get_value(pkgarea,"version");
    }
}

public string[] list_installed_packages(){
    string[] pkgs = {};
    foreach(string fname in listdir(DESTDIR+STORAGEDIR+"/metadata")){
        pkgs += fname.split(".")[0];
    }
    return pkgs;
}
public package get_installed_packege(string name){
    package pkg = new package();
    string metadata = DESTDIR+STORAGEDIR+"/metadata/"+name+".yaml";
    debug("Loading package metadata from: "+metadata);
    pkg.load(metadata);
    return pkg;
}
