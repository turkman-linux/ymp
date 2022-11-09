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
                pkg.set_pkgarea(area,true);
                pkg.repo_address = address;
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
            if(area == null){
                continue;
            }
            if (yaml.get_value(area,"name") == name){
                pkg = new package();
                pkg.set_pkgarea(area,false);
                pkg.repo_address = address;
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
            if(area != ""){
                ret += yaml.get_value(area,"name");
            }
        }
        return ret;
    }

    //DOC: `string[] repository.list_sources():`
    //DOC: get all available source names from repository
    public string[] list_sources(){
        string[] ret = {};
        foreach(string area in sources){
            if(area != ""){
                ret += yaml.get_value(area,"name");
            }
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
    string force_repo = get_value("repo");
    if(repos == null){
        repos = {};
    }else{
        return repos;
    }
    foreach(string file in listdir(get_storage()+"/index")){
        repository repo = new repository();
        repo.load(file);
        if(force_repo == "" || force_repo == repo.name){
            repos += repo;
        }
    }
    return repos;
}

//DOC: `bool is_available_package(string name):`
//DOC: return true if package is available
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
                pkg.repo_address = repo.address.replace("ymp-index.yaml","$uri");
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
    if(get_bool("emerge")){
        return get_source_from_repository(name);
    }else{
        return get_package_from_repository(name);
    }
}


//DOC: `package get_package_from_file(string path):`
//DOC: get package object from ymp file archive
public package get_package_from_file(string path){
    package pkg = new package();
    pkg.load_from_archive(srealpath(path));
    return pkg;
}

//DOC: `string[] get_repo_address():`
//DOC: return repository adress list
public string[] get_repo_address(){
    string repolist = "";
    info("Find repo list: "+get_storage()+"/sources.list");
    if(isdir(get_storage()+"/sources.list.d")){
        foreach(string file in find(get_storage()+"/sources.list.d")){
            if(isfile(file)){
                info("Find repo list: "+file);
                repolist += readfile(file)+"\n";
            }
        }
    }
    repolist += readfile(get_storage()+"/sources.list")+"\n";
    return ssplit(repolist,"\n");
}

//DOC: `void update_repo():`
//DOC: update local repository index
public void update_repo(){
    remove_all(get_storage()+"/index");
    create_dir(get_storage()+"/index");
    foreach(string repo in get_repo_address()){
        if(repo == "" || repo == null){
            continue;
        }
        string repox = repo;
        repo = repo.replace("$uri","ymp-index.yaml");
        string name = repo.replace("/","-");
        string path = get_storage()+"/index/"+name;
        fetch(repo,path);
        string index_data = readfile(path);
        index_data += "\n  address: "+repox;
        writefile(path,index_data);
    }
}

public string[] list_available_packages(){
    string[] ret = {};
    foreach(repository repo in get_repos()){
        if(get_bool("emerge")){
            foreach(string name in repo.list_sources()){
                ret += name;
            }
        }else{
            foreach(string name in repo.list_packages()){
                ret += name;
            }
       }
    }
    return ret;
}

//DOC: `string create_index_data(string fpath):`
//DOC: generate remote repository index data
public string create_index_data(string fpath){
    string index = "index:\n";
    string md5sum = "";
    int size=0;
    string path = srealpath(fpath);
    string index_name = get_value("name");
    if(index_name == ""){
        error_add("Index name not defined. Please use --name=xxx");
        error(1);
    }
    var tar = new archive();
    var yaml = new yamlfile();
    index += "  name: "+index_name+"\n";
    foreach(string file in find(path)){
        if(endswith(file,".ymp")){
            if(get_bool("move")){
                string fname = sbasename(file);
                string dir=fname[:1];
                if(startswith(fname,"lib")){
                    dir=fname[:4];
                }
                dir = dir+"/"+ssplit(fname,"_")[0]+"/";
                string target = srealpath(path+"/"+dir+fname);
                if(srealpath(file) != target){
                    create_dir(path+"/"+dir);
                    move_file(file,target);
                    file = target;
                }
            }
            md5sum = calculate_md5sum(file);
            size = filesize(file);
            tar.load(file);
            file = file[path.length:];
            info("Index: "+file);
            string metadata = tar.readfile("metadata.yaml");
            string ymparea = yaml.get_area(metadata,"ymp");
            foreach(string line in ssplit(ymparea,"\n")){
                if(line == "" || line == null){
                    continue;
                }
                index += "  "+line+"\n";
            }
            index+="    md5sum: "+md5sum+"\n";
            index+="    size: "+size.to_string()+"\n";
            index+="    uri: "+file+"\n\n";
        }
    }
    return index;
}
