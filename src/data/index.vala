public class repository {
    private yamlfile yaml;
    public string name;
    private string indexarea;
    public string[] packages;
    
    public void load(string path){
        yaml = new yamlfile();
        yaml.load(path);
        indexarea = yaml.get("index");
        name = yaml.get_value(indexarea,"name");
        packages = yaml.get_area_list(indexarea,"package");
        
    }
    
    public bool has_package(string name){
        foreach(string area in packages){
            var pkgarea = yaml.get_area(area,"package");
            if (yaml.get_value(pkgarea,"name") == name){
                return true;
            }
        }
        return false;
    }
    public package get_package(string name){
        package pkg = new package();
        foreach(string area in packages){
            var pkgarea = yaml.get_area(area,"package");
            if (yaml.get_value(pkgarea,"name") == name){
                pkg.load_from_data(pkgarea);
                return pkg;
            }
        }
        return pkg;
    }
}

public repository[] get_repos(){
    repository[] repos = {};
    foreach(string file in listdir(get_value("DESTDIR")+STORAGEDIR+"/index")){
        repository repo = new repository();
        repo.load(get_value("DESTDIR")+STORAGEDIR+"/index/"+file);
        repos += repo;
    }
    return repos;
}
