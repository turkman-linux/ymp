//DOC: ## Dependency analysis
//DOC: resolve dependencies
private array need_install;
private array cache_list;

private void resolve_process(string[] names){
    foreach(string name in names){
        info("Resolve dependency: "+name);
        // 1. block process packages for multiple times.
        if(cache_list.has(name)){
            continue;
        }else{
            cache_list.add(name);
        }
        if(name[0] == '@'){
            string[] grp = get_group_packages(name);
            resolve_process(grp);
            continue;
        }
        // 2. process if not installed or need install
        if (!need_install.has(name)){
            // get package object
            package pkg = null;
            if(isfile(name)){
                pkg = get_package_from_file(name);
            }else{
                pkg = get_from_repository(name);
            }
            if(pkg == null){
                continue;
            }
            if(!get_bool("reinstall") && is_installed_package(name)){
                if(pkg.release <= get_installed_package(name).release){
                    continue;
                }
            }
            // run recursive function
            resolve_process(pkg.dependencies);
            // add package to list
            debug(name);
            need_install.add(name);
        }
    }
}

private string[] get_group_packages(string fname){
    info("Resolve group: "+fname);
    array ret = new array();
    string[] pkgnames = list_available_packages();
    string name = fname[1:];
    foreach(string pkgname in pkgnames){
        package p = get_from_repository(pkgname);
        if(p == null){
            continue;
        }
        foreach(string grp in p.gets("group")){
            if(name == grp || startswith(grp,name+".")){
                debug("Group "+grp+": add "+pkgname);
                ret.add(pkgname);
            }
        }
    }
    return ret.get();
}

private void resolve_reverse_process(string[] names){
    string[] pkgnames = list_installed_packages();
    foreach(string name in names){
        if(cache_list.has(name)){
            continue;
        }else{
            cache_list.add(name);
        }
        if(name[0] == '@'){
            string[] grp = get_group_packages(name);
            resolve_reverse_process(grp);
            continue;
        }
        info("Resolve reverse dependency: "+name);
        need_install.add(name);

        foreach(string pkgname in pkgnames){
            package pkg = get_installed_package(pkgname);
            if(name in pkg.dependencies){
                string[] tmp = {pkgname};
                resolve_reverse_process(tmp);
            }
        }
    }
}

//DOC: `string[] resolve_dependencies(string[] names):`
//DOC: return package name list with required dependencies
public string[] resolve_dependencies(string[] names){
    // reset need list
    need_install = new array();
    // reset cache list
    cache_list = new array();
    if(get_bool("ignore-dependency")){
        foreach(string name in names){
            if(name[0] == '@'){
                need_install.adds(get_group_packages(name));
            }else{
                need_install.add(name);
            }
        }
    }else{
        // process
        resolve_process(names);
    }
    error(3);
    return need_install.get();
}

//DOC: `string[] resolve_reverse_dependencies(string[] names):`
//DOC: return package name list with required reverse dependencies
public string[] resolve_reverse_dependencies(string[] names){
    // reset need list
    need_install = new array();
    // reset cache list
    cache_list = new array();
    if(get_bool("ignore-dependency")){
        foreach(string name in names){
            if(name[0] == '@'){
                need_install.adds(get_group_packages(name));
            }else{
                need_install.add(name);
            }
        }
    }else{
        resolve_reverse_process(names);
    }
    error(3);
    return need_install.get();
}
