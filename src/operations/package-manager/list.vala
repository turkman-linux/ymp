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
    if(get_bool("digraph")){
        print("digraph {");
    }
    foreach(repository repo in get_repos()){
        if(args.length > 0 && !(repo.name in args)){
            continue;
        }
        if(get_bool("digraph")){
            string[] names = {};
            if(get_bool("source")){
                names = repo.list_sources();
            }else{
                names = repo.list_packages();
            }
            foreach(string name in names){
                var pkg = repo.get_package(name);
                if(pkg == null){
                    continue;
                }
                string[] deps = pkg.gets("depends");
                foreach(string dep in deps){
                    print("\"%s\" -> \"%s\"".printf(dep,name));
                }
                if(is_installed_package(name)){
                    print("\"%s\" [style=filled fillcolor=green]".printf(name));
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
    if(get_bool("digraph")){
        print("}");
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
    
    h.name = _("list");
    h.description = _("List installed packages.");
    h.add_parameter("--installed", _("list installed packages"));
    h.add_parameter("--digraph", _("write as graphwiz format"));
    h.add_parameter("--repository", _("list repositories"));
    h.add_parameter("--source", _("list available source packages"));

    add_operation(list_main,{_("list"),"list","ls"},h);
}
