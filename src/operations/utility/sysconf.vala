public int sysconf_main(string[] args){
    if(!is_root() || get_bool("no-sysconf")){
        return 0;
    }
    set_env("OPERATION",get_value("OPERATION"));
    if(DESTDIR != "/"){
        run_args({"chroot", get_destdir(), "ldconfig"});
    }else{
        run("ldconfig");
    }
    foreach(string hook in find(get_configdir()+"/sysconf.d")){
        if(isfile(hook)){
            info(_("Run hook: %s").printf(sbasename(hook)));
            create_dir(get_storage()+"/sysconf/"+sbasename(hook));
            if(DESTDIR != "/"){
                hook=hook[DESTDIR.length:];
                if(0 != run_args({"chroot", get_destdir(), hook})){
                    warning(_("Failed to run sysconf: %s").printf(sbasename(hook)));
                }
            }else if(0 != run(hook)){
                warning(_("Failed to run sysconf: %s").printf(sbasename(hook)));
            }
        }
    }
    set_env("STORAGE","");
    return 0;
}

void sysconf_init(){
    var h = new helpmsg();
    h.name = _("sysconf");
    h.description = _("Trigger sysconf operations.");
    add_operation(sysconf_main, {_("sysconf"),"sc","sysconf"},h);
}
