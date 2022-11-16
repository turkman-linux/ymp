public int list_main(string[] args){
    if(get_bool("installed")){
        return list_installed_main(args);
    }else if(get_bool("repository")){
        return list_repository_main(args);
    }else{
        return list_available_main(args);
    }
}

public int list_installed_main(string[] args){
    foreach(string pkg in list_installed_packages()){
        var p = get_installed_package(pkg);
        print(colorize(pkg,green)+"\t"+p.get("description"));
    }
    return 0;
}

public int list_available_main(string[] args){
    foreach(repository repo in get_repos()){
        if(args.length > 0 && !(repo.name in args)){
            continue;
        }
        if(get_bool("source")){
           foreach(string name in repo.list_sources()){
                var pkg = repo.get_package(name);
                if(pkg == null){
                    continue;
                }
                var description = pkg.get("description");
                if(is_installed_package(name)){
                    print(repo.name+":"+colorize("source ",blue) + " "+colorize(name,green) + " " + description);
                }else{
                    print(repo.name+":"+colorize("source ",blue) + " "+colorize(name,red) + " " + description);
                }
            }
        }else{
            foreach(string name in repo.list_packages()){
                var pkg = repo.get_package(name);
                if(pkg == null){
                    continue;
                }
                var description = pkg.get("description");
                if(is_installed_package(name)){
                    print(repo.name+":"+colorize("package",blue) + " "+colorize(name,green) + "\t" + description);
                }else{
                    print(repo.name+":"+colorize("package",blue) + " "+colorize(name,red) + "\t" + description);
                }
            }
        }
    }
    return 0;
}


public int list_repository_main(string[] args){
    foreach(repository repo in get_repos()){
        print_fn(colorize(repo.name,green)+" :: ",false,false);
        print_fn(repo.address+" :: ",false,false);
        print_fn(colorize("("+repo.packages.length.to_string()+" binary)",cyan)+" :: ",false,false);
        print_fn(colorize("("+repo.sources.length.to_string()+" source) ",magenta),false,false);
        print("");
        
    }
    return 0;
}

void list_init(){
    var h = new helpmsg();
    
    h.name = "list";
    h.description = "List installed packages.";
    h.add_parameter("--installed","list installed packages");
    h.add_parameter("--repository","list repositories");
    h.add_parameter("--source","list available source packages");

    add_operation(list_main,{"list","ls"},h);
}
