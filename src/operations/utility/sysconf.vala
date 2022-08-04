public int sysconf_main(string[] args){
    foreach(string hook in find(CONFIGDIR+"/inary.d")){
        if(isfile(hook)){
            if(0 != run_args({"sh","-c",hook})){
                warning("Failed to run hook: "+hook);
            }
        }
    }
    return 0;
}

void sysconf_init(){
    add_operation(sysconf_main, {"sc","sysconf"});
}
