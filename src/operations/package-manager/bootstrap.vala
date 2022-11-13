public int bootstrap_main(string[] args){
    if(!is_root()){
        error_add("You must be root!");
    }
    string repo=get_value("mirror");
    string rootfs=srealpath(get_value("destdir"));
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
    string[] base_packages = {"busybox", "base-files", "glibc"};
    foreach(string dir in basedir){
        create_dir(rootfs+"/"+dir);
        GLib.FileUtils.chmod(rootfs+"/"+dir,0755);
        Posix.chown(rootfs+"/"+dir,0,0);
    }
    GLib.FileUtils.chmod(rootfs+"/tmp",0777);
    bool sysconf = get_bool("no-sysconf");
    set_bool("no-sysconf",true);
    set_destdir(rootfs);
    copy_file("/etc/resolv.conf",rootfs+"/etc/resolv.conf");
    writefile(rootfs+"/"+STORAGEDIR+"/sources.list",repo+"\n");
    writefile(rootfs+"/"+STORAGEDIR+"/restricted.list","/data/user\n");
    update_main(args);
    install_main(base_packages);
    foreach(string package in base_packages){
        string hook = get_configdir()+"/sysconf.d/";
        hook = hook[get_destdir().length:];
        run_args({"chroot", get_destdir(), hook+package});
    }
    install_main(args);
    set_bool("no-sysconf",sysconf);
    sysconf_main(args);
    return 0;
}

void bootstrap_init(){
    var h = new helpmsg();
    h.name = "bootstrap";
    h.description = "Create new rootfs filesystem.";
    h.add_parameter("--mirror", "bootstrap mirror uri");
    add_operation(bootstrap_main,{"bootstrap","bst"},h);
}
