public int sysconf_main(string[] args){
    set_env("OPERATION",get_value("OPERATION"));
    foreach(string hook in find(get_configdir()+"/sysconf.d")){
        if(isfile(hook)){
            if(DESTDIR != "/"){
                if(0 != run_args({"chroot", DESTDIR, hook})){
                    warning("Failed to run hook: "+hook);
                }
            }else if(0 != run(hook)){
                warning("Failed to run hook: "+hook);
            }
        }
    }
    return 0;
}

void sysconf_init(){
    var h = new helpmsg();
    h.name = "sysconf";
    h.description = "Trigger sysconf operations.";
    add_operation(sysconf_main, {"sc","sysconf"},h);
}
