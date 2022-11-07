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
                var pkg = repo.get_package(name);
                if(pkg == null){
                    continue;
                }
                var description = pkg.get("description");
                if(is_installed_package(name)){
                    print(colorize("package",blue) + " "+colorize(name,green) + " " + description);
                }else{
                    print(colorize("package",blue) + " "+colorize(name,red) + " " + description);
                }
            }
        }else if(get_bool("source")){
           foreach(string name in repo.list_sources()){
                var pkg = repo.get_package(name);
                if(pkg == null){
                    continue;
                }
                var description = pkg.get("description");
                if(is_installed_package(name)){
                    print(colorize("source ",blue) + " "+colorize(name,green) + " " + description);
                }else{
                    print(colorize("source ",blue) + " "+colorize(name,red) + " " + description);
                }
            }
        }
    }
    return 0;
}


void list_init(){
    var h1 = new helpmsg();
    var h2 = new helpmsg();
    
    h1.name = "list-installed";
    h1.description = "List installed packages.";

    h2.name = "list-available";
    h2.description = "List available packages.";

    add_operation(list_installed_main,{"list-installed","li"},h1);
    add_operation(list_available_main,{"list-available","la"},h2);
}
