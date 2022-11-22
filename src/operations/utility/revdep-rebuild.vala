public int revdep_rebuild_main(string[] args){
    ymp_init(args);
    set_env("LANG","C");
    set_env("LC_ALL","C");
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
    print_fn("\x1b[2K\r",false,true);
    return 0;
}

private string ldddata;
public void check(string file){
    print_fn("\x1b[2K\rChecking: "+file,false,true);
    ldddata = getoutput("ldd "+file+" 2>/dev/null");
    foreach(string line in ssplit(ldddata,"\n")){
        if(endswith(line,"not found")){
            print_fn("\x1b[2K\r",false,true);
            print(colorize(file,red) +" => "+ line[1:line.length-13]);
        }
    }
}

void revdep_rebuild_init(){
    var h = new helpmsg();
    h.name = "revdep-rebuild";
    h.description = "Check library for broken link.";
    add_operation(revdep_rebuild_main,{"revdep-rebuild","rbd"},h);
}
