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
    public string address;
    private string indexarea;
    public string[] packages;
    public string[] sources;

    //DOC: `void repository.load(string repo_name):`
    //DOC: load repository data from repo name
    public void load(string repo_name){
        yaml = new yamlfile();
        yaml.load(get_storage()+"/index/"+repo_name);
        indexarea = yaml.get("index");
        name = yaml.get_value(indexarea,"name");
        address = yaml.get_value(indexarea,"address");
        packages = yaml.get_area_list(indexarea,"package");
        sources = yaml.get_area_list(indexarea,"source");

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

    //DOC: `package repository.get_source(string name):`
    //DOC: get package object from repository by source name
    public package get_source(string name){
        package pkg = null;
        foreach(string area in sources){
            if (yaml.get_value(area,"name") == name){
                pkg = new package();
                pkg.load_from_data(area);
                return pkg;
            }
        }
        return pkg;
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

    //DOC: `string[] repository.list_sources():`
    //DOC: get all available source names from repository
    public string[] list_sources(){
        string[] ret = {};
        foreach(string area in sources){
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

public bool is_available_package(string name){
    foreach(repository repo in get_repos()){
        if(repo.has_package(name)){
            return true;
        }
    }
    return false;
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
                pkg.repo_address = repo.address;
                release = int.parse(pkg.get("release"));
            }
        }
    }
    if(ret == null){
        error_add("Package not satisfied from repository: "+name);
    }
    return ret;
}

//DOC: `package get_source_from_repository(string name):`
//DOC: get source package object from all repositories
public package get_source_from_repository(string name){
    int release = 0;
    package ret = null;
    foreach(repository repo in get_repos()){
        package pkg = repo.get_source(name);
        if(pkg != null){
            if(int.parse(pkg.get("release")) > release){
                ret = pkg;
                pkg.repo_address = repo.address;
                release = int.parse(pkg.get("release"));
            }
        }
    }
    if(ret == null){
        error_add("Package not satisfied from repository: "+name);
    }
    return ret;
}

//DOC: `package get_from_repositony(stning name):`
//DOC: return source if emerge else return package
public package get_from_repository(string name){
    if(get_bool("--emerge")){
        return get_source_from_repository(name);
    }else{
        return get_package_from_repository(name);
    }
}


//DOC: `package get_package_from_file(string path):`
//DOC: get package object from inary file archive
public package get_package_from_file(string path){
    package pkg = new package();
    pkg.load_from_archive(path);
    return pkg;
}

public string[] get_repo_address(){
    string repolist = readfile(get_storage()+"/sources.list")+"\n";
    if(isdir(get_storage()+"/sources.list.d")){
        foreach(string file in find(get_storage()+"/sources.list.d")){
        repolist += readfile(file)+"\n";
        }
    }
    return ssplit(repolist,"\n");
}

public void update_repo(){
    remove_all(get_storage()+"/index");
    create_dir(get_storage()+"/index");
    foreach(string repo in get_repo_address()){
        if(repo == "" || repo == null){
            continue;
        }
        string name = repo.replace("/","-");
        fetch(repo,get_storage()+"/index/"+name);
    }
}

public string create_index_data(string fpath){
    string index = "index:\n";
    string path = srealpath(fpath);
    var tar = new archive();
    var yaml = new yamlfile();
    foreach(string file in find(path)){
        if(endswith(file,".inary")){
            tar.load(file);
            file = file[path.length:];
            info("Index: "+file);
            string metadata = tar.readfile("metadata.yaml");
            string inaryarea = yaml.get_area(metadata,"inary");
            foreach(string line in ssplit(inaryarea,"\n")){
                if(line == "" || line == null){
                    continue;
                }
                index += "  "+line+"\n";
            }
            index+="    uri: "+file+"\n\n";
        }
    }
    return index;
}
