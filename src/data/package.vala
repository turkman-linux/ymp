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
