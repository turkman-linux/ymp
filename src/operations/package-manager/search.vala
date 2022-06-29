public int search_main(string[] args){
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

void search_init(){
    add_operation(search_main,{"search","sr"});
    add_operation(search_pkgrepo_main,{"search-package","sp"});
    add_operation(search_srcrepo_main,{"search-source","ss"});
}
