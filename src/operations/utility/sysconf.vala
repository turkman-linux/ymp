public int sysconf_main(string[] args){
    if(!is_root() || get_bool("no-sysconf")){
        return 0;
    }
    set_env("OPERATION",get_value("OPERATION"));
    foreach(string hook in find(get_configdir()+"/sysconf.d")){
        if(isfile(hook)){
            info("Run hook:"+sbasename(hook));
            if(DESTDIR != "/"){
                hook=hook[DESTDIR.length:];
                create_dir(get_storage()+"/sysconf/"+sbasename(hook));
                if(0 != run_args({"chroot", get_destdir(), hook})){
                    warning("Failed to run sysconf: "+sbasename(hook));
                }
            }else if(0 != run(hook)){
                warning("Failed to run sysconf: "+sbasename(hook));
            }
        }
    }
    set_env("STORAGE","");
    return 0;
}

void sysconf_init(){
    var h = new helpmsg();
    h.name = "sysconf";
    h.description = "Trigger sysconf operations.";
    add_operation(sysconf_main, {"sc","sysconf"},h);
}
