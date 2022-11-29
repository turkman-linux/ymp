public int index_main(string[] args){
    foreach(string arg in args){
        string path = srealpath(arg);
        string index = create_index_data(path);
        writefile(path+"/ymp-index.yaml",index);
    }
    return 0;
}

public int update_main(string[] args){
    if(!is_root()){
        error_add("You must be root!");
        error(1);
    }
    single_instance();
    update_repo();
    return 0;
}

public int repo_add_main(string[] args){
    if(get_value("name") == "" ){
        error_add("name not defined.");
    }else{
        string data = "";
        foreach(string arg in args){
            data += arg + "\n";
        }
        if(args.length == 0){
            error_add("Repository uri not defined.");
        }
        create_dir(get_storage()+"/sources.list.d/");
        writefile(get_storage()+"/sources.list.d/"+get_value("name"),data);
    }
    error(1);
    return 0;
}

public int repo_remove_main(string[] args){
    foreach(string arg in args){
        remove_file(get_storage()+"/sources.list.d/"+arg);
    }
    return 0;
}

public int repo_list_main(string[] args){
    string[] repos = find(get_storage()+"/sources.list.d/");
    repos += get_storage()+"/sources.list";
    foreach (string repofile in repos){
        if(isfile(repofile)){
            string fname = sbasename(repofile);
            print("%s:".printf(colorize(fname,green)));
            foreach(string uri in ssplit(readfile(repofile),"\n")){
                if(uri != ""){
                    print("  - "+uri);
                }
            }
        }
    }
    return 0;
}

public int repository_main(string[] args){
    if(get_bool("update")){
        return update_main(args);
    }else if(get_bool("mirror")){
        return mirror_main(args);
    }else if(get_bool("index")){
        return index_main(args);
    }else if(get_bool("add")){
        return repo_add_main(args);
    }else if(get_bool("remove")){
        return repo_remove_main(args);
    }else if(get_bool("list")){
        return repo_list_main(args);
    }
    return 0;
}

public int mirror_main(string[] args){
    string target = srealpath(get_value("destdir"));
    if(target == ""){
        target=srealpath(".");
    }
    create_dir(target);
    foreach(string arg in args){
        foreach(repository repo in get_repos()){
            if(repo.name == arg || arg == "*"){
                if(!get_bool("no-package")){
                    foreach(string name in repo.list_packages()){
                        print(colorize("Mirror :",yellow)+repo.name+" => "+name+" (binary)");
                        var pkg = repo.get_package(name);
                        mirror_download(pkg, target);
                    }
                }
                if(!get_bool("no-source")){
                    foreach(string name in repo.list_sources()){
                        var pkg = repo.get_source(name);
                        print(colorize("Mirror :",yellow)+repo.name+" => "+name+" (source)");
                        mirror_download(pkg, target);
                    }
                }
            }
        }
    }
    if(get_bool("index")){
        index_main({target});
    }
    return 0;
}


private void mirror_download(package pkg,string target){
    if(pkg == null){
         return;
    }
    string file = target+pkg.get("uri");
    create_dir(sdirname(file));
    if(!isfile(file)){
        fetch(pkg.get_uri(),file);
    }
}

void repository_init(){
    var h = new helpmsg();
    h.name = "repository";
    h.description = "Update / Index / Mirror repository";
    h.add_parameter("--update", "update repository");
    h.add_parameter("--index", "index repository");
    h.add_parameter("--add", "add new repository file");
    h.add_parameter("--remove", "remove repository file");
    h.add_parameter("--list", "list repository files");
    h.add_parameter("--mirror", "mirror repository");
    h.add_parameter(colorize("Index options",magenta),"");
    h.add_parameter("--move", "move packages for alphabetical hierarchy");
    h.add_parameter("--name", "new repository name (required)");
    h.add_parameter(colorize("Add options",magenta),"");
    h.add_parameter("--name","new file name");
    h.add_parameter(colorize("Mirror options",magenta),"");
    h.add_parameter("--no-package","Do not mirror binary packages");
    h.add_parameter("--no-source","Do not mirror source packages");
    h.add_parameter("--index","Index after mirror.");
    h.add_parameter("--destdir","Target mirror directory");
    add_operation(repository_main,{"repository","repo"}, h);
}
