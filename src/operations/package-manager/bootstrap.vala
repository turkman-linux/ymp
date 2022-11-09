public int bootstrap_main(string[] args){
    if(!is_root()){
        error_add("You must be root!");
    }
    string repo=get_value("mirror");
    if(repo == ""){
        error_add("Mirror is not defined. Please use --mirror .");
    }if(DESTDIR=="/"){
        error_add("Destdir is not defined. Please use --destdir .");
    }
    if(isfile(DESTDIR+"/etc/os-release")){
        error_add("Target rootfs already exists: "+DESTDIR);
    }
    error(2);
    print(colorize("Creating bootstrap:",blue));
    string[] basedir = {"dev", "sys", "proc", "run"};
    foreach(string dir in basedir){
        create_dir(DESTDIR+"/"+dir);
    }
    writefile(DESTDIR+"/var/lib/ymp/sources.list",repo+"\n");
    update_main(args);
    install_main({"glibc", "base-files", "busybox"});
    install_main(args);
    return 0;
}

void bootstrap_init(){
    var h = new helpmsg();
    h.name = "bootstrap";
    h.description = "Create new rootfs filesystem.";
    h.add_parameter("--mirror", "bootstrap mirror uri");
    add_operation(bootstrap_main,{"bootstrap","bst"},h);
}
