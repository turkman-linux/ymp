public int mirror_main(string[] args){
    string target = srealpath(get_value("output"));
    if(target == ""){
        target=srealpath(".");
    }
    create_dir(target);
    print(target);
    foreach(string arg in args){
        foreach(repository repo in get_repos()){
            if(repo.name == arg || arg == "*"){
                if(get_bool("package")){
                    foreach(string name in repo.list_packages()){
                        var pkg = repo.get_package(name);
                        mirror_download(pkg, target);
                    }
                }
                if(get_bool("source")){
                    foreach(string name in repo.list_sources()){
                        var pkg = repo.get_source(name);
                        mirror_download(pkg, target);
                    }
                }
            }
        }
    }
    index_operation({target});
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

void mirror_init(){
    var h = new helpmsg();
    
    h.name = "mirror";
    h.minargs = 1;
    h.description = "Mirror repository";
    h.add_parameter("--package","Mirror binary packages");
    h.add_parameter("--source","Mirror source packages");
    h.add_parameter("--output","Mirror output directory");
    h.add_parameter("--name","New repository index name");

    add_operation(mirror_main,{"mirror","mr"},h);
}
