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
            if (yaml.get_value(area,"name") == name){
                return true;
            }
        }
        return false;
    }
    public package get_package(string name){
        package pkg = new package();
        foreach(string area in packages){
            if (yaml.get_value(area,"name") == name){
                pkg.load_from_data(area);
                return pkg;
            }
        }
        return pkg;
    }
    public string[] list_packages(){
        string[] ret = {};
        foreach(string area in packages){
            ret += yaml.get_value(area,"name");
        }
        return ret;
    }
}

public repository[] get_repos(){
    repository[] repos = {};
    foreach(string file in listdir(get_storage()+"/index")){
        repository repo = new repository();
        repo.load(get_storage()+"/index/"+file);
        repos += repo;
    }
    return repos;
}
