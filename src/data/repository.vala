//DOC: ## class repository
//DOC: repository object to list or select packages from repository
//DOC: Example usage:
//DOC: ```vala
//DOC: var repo = new repository();
//DOC: repo.load("main.yaml");
//DOC: if(repo.has_package("bash")){
//DOC:     stdout.printf("Package found.");
//DOC: }
//DOC: foreach(string name in repo.list_packages()){
//DOC:     package pkg = repo.get_package(name);
//DOC:     stdout.printf(pkg.version);
//DOC: }
//DOC: ```
public class repository {
    private yamlfile yaml;
    public string name;
    private string indexarea;
    public string[] packages;

    //DOC: `void repository.load(string repo_name):`
    //DOC: load repository data from repo name
    public void load(string repo_name){
        yaml = new yamlfile();
        yaml.load(get_storage()+"/index/"+repo_name);
        indexarea = yaml.get("index");
        name = yaml.get_value(indexarea,"name");
        packages = yaml.get_area_list(indexarea,"package");

    }

    //DOC: `bool repository.has_package(string name):`
    //DOC: return true if package exists in repository
    public bool has_package(string name){
        foreach(string area in packages){
            if (yaml.get_value(area,"name") == name){
                return true;
            }
        }
        return false;
    }

    //DOC: `package repository.get_package(string name):`
    //DOC: get package object from repository by package name
    public package get_package(string name){
        package pkg = null;
        foreach(string area in packages){
            if (yaml.get_value(area,"name") == name){
                pkg = new package();
                pkg.load_from_data(area);
                return pkg;
            }
        }
        return pkg;
    }

    //DOC: `string[] repository.list_packages():`
    //DOC: get all available package names from repository
    public string[] list_packages(){
        string[] ret = {};
        foreach(string area in packages){
            ret += yaml.get_value(area,"name");
        }
        return ret;
    }
}

//DOC: ## Miscellaneous repository functions
//DOC: repository functions outside repository class

private repository[] repos;
//DOC: `repository[] get_repos():`
//DOC: get all repositories as array
public repository[] get_repos(){
    if(repos == null){
        repos = {};
    }else{
        return repos;
    }
    foreach(string file in listdir(get_storage()+"/index")){
        repository repo = new repository();
        repo.load(file);
        repos += repo;
    }
    return repos;
}

//DOC: `package get_package_from_repository(string name):`
//DOC: get package object from all repositories
public package get_package_from_repository(string name){
    int release = 0;
    package ret = null;
    foreach(repository repo in get_repos()){
        package pkg = repo.get_package(name);
        if(pkg != null){
            if(int.parse(pkg.get("release")) > release){
                ret = pkg;
                release = int.parse(pkg.get("release"));
            }
        }
    }
    if(ret == null){
        error_add("Package not satisfied: "+name);
    }
    return ret;
}
