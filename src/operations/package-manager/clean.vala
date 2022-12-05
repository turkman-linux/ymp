public int clean_main(string[] args){
    print(colorize("Clean: ",yellow)+"package cache");
    remove_all(get_storage()+"/packages");
    print(colorize("Clean: ",yellow)+"repository index cache");
    remove_all(get_storage()+"/index");
    print(colorize("Clean: ",yellow)+"build directory");
    remove_all(DESTDIR+"/tmp/ymp-build/");
    print(colorize("Clean: ",yellow)+"quarantine");
    quarantine_reset();
    return 0;
}

void clean_init(){
    var h = new helpmsg();
    h.name = "clean";
    h.description = "Remove all caches ";
    add_operation(clean_main,{"clean","cc"},h);
}
