public int search_main(string[] args){
    if(get_bool("package-repo")){
        return search_pkgrepo_main(args);
    }
    if(get_bool("source-repo")){
        return search_srcrepo_main(args);
    }
    if(get_bool("file")){
        return search_files_main(args);
    }
    foreach(string pkg in list_installed_packages()){
        var p = get_installed_package(pkg);
        foreach(string arg in args){
            if(arg in p.get("description") || arg in p.name){
                print((p.name+"\t"+p.get("description")).replace(arg,colorize(arg,red)));
            }
        }
    }
    return 0;
}

public int search_pkgrepo_main(string[] args){
    foreach(repository repo in get_repos()){
        foreach(string pkg in repo.list_packages()){
            var p = repo.get_package(pkg);
            foreach(string arg in args){
                if(arg in p.get("description") || arg in p.name){
                    print((p.name+"\t"+p.get("description")).replace(arg,colorize(arg,red)));
                }
            }
        }
    }
    return 0;
}

public int search_srcrepo_main(string[] args){
    foreach(repository repo in get_repos()){
        foreach(string pkg in repo.list_sources()){
            var p = repo.get_source(pkg);
            foreach(string arg in args){
                if(arg in p.get("description") || arg in p.name){
                    print((p.name+"\t"+p.get("description")).replace(arg,colorize(arg,red)));
                }
            }
        }
    }
    return 0;
}

public int search_files_main(string[] args){
    foreach(string pkg in list_installed_packages()){
        string files = readfile(get_storage()+"/files/"+pkg);
        foreach(string file in files.split("\n")){
            if(file.length < 41){
                continue;
            }
            foreach(string arg in args){
                if(arg in "/"+file[41:]){
                    print("Found: "+pkg+" => /"+file[41:]);
                }
            }
        }
    }
    return 0;
}

void search_init(){
    var h = new helpmsg();
    h.name = "search";
    h.description = "Search packages";
    h.add_parameter("--package-repo", "Search package in binary package repository.");
    h.add_parameter("--source-repo", "Search package in source package repository.");
    h.add_parameter("--file", "Searches for packages by package file.");
    add_operation(search_main,{"search","sr"},h);
}
