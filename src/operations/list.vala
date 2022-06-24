public int list_installed_main(string[] args){
    foreach(string pkg in list_installed_packages()){
        var p = get_installed_package(pkg);
        print(pkg+"\t"+p.get("description"));
    }
    return 0;
}

public int list_available_main(string[] args){
    foreach(repository repo in get_repos()){
        if(get_bool("package")){
            foreach(string name in repo.list_packages()){
                var description = repo.get_package(name).get("description");
                print(name + " " + description);
            }
        } if(get_bool("source")){
           foreach(string name in repo.list_sources()){
                var description = repo.get_source(name).get("description");
                print(name + " " + description);
            }
        }
    }
    return 0;
}


public void list_init(){
    add_operation(list_installed_main,{"list-installed","li"});
    add_operation(list_available_main,{"list-available","la"});
}
