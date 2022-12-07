public int revdep_rebuild_main(string[] args){
    ymp_init(args);
    set_env("LANG","C");
    set_env("LC_ALL","C");
    if(get_bool("pkgconfig")){
        string[] paths = {
            "/lib64/pkgconfig",
            "/usr/lib64/pkgconfig",
            "/usr/share/pkgconfig"
        };
        foreach(string path in paths){
            foreach(string file in find(path)){
                if(endswith(file,".pc")){
                    check_pkgconfig(file);
                }
            }
        }
        print_fn("\x1b[2K\r",false,true);
    }else{
        writefile("/tmp/.empty.c","");
        string[] paths = {
            "/lib","/lib64","/usr/lib","/usr/lib64",
            "/lib32","/usr/lib32","/libx32","/usr/libx32",
        };
        foreach(string path in paths){
            foreach(string file in find(path)){
                if(endswith(file,".so")){
                    check(file);
                }
            }
        }
        paths = {"/bin","/sbin","/usr/bin","/usr/sbin","/usr/libexec"};
        foreach(string path in paths){
            foreach(string file in find(path)){
                check(file);
            }
        }
        remove_file("/tmp/.empty.c");
        print_fn("\x1b[2K\r",false,true);
    }
    return 0;
}

private string ldddata;
public void check(string file){
    print_fn("\x1b[2K\r"+_("Checking: %s").printf(file),false,true);
    ldddata = getoutput("ldd "+file+" 2>/dev/null");
    foreach(string line in ssplit(ldddata,"\n")){
        if(endswith(line,"not found")){
            print_fn("\x1b[2K\r",false,true);
            print(colorize(file,red) +" => "+ line[1:line.length-13]);
        }
    }
}
public void check_pkgconfig(string file){
    print_fn("\x1b[2K\r"+_("Checking: %s").printf(file),false,true);
    int status = run("gcc `pkg-config --cflags --libs "+file+"` /tmp/.empty.c -shared -o /dev/null 2>/dev/null");
    if(status != 0){
        print_fn("\x1b[2K\r",false,true);
        print(colorize(file,red)+" "+"broken.");
    }

}

void revdep_rebuild_init(){
    var h = new helpmsg();
    h.name = _("revdep-rebuild");
    h.description = _("Check library for broken link.");
    h.add_parameter("--pkgconfig",_("check pkgconfig files"));
    add_operation(revdep_rebuild_main,{_("revdep-rebuild"),"revdep-rebuild","rbd"},h);
}
