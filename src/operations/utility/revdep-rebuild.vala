public int revdep_rebuild_main(string[] args){
    set_env("LANG","C");
    set_env("LC_ALL","C");
    if(get_bool("pkgconfig")){
        writefile("/tmp/.empty.c","");
        string[] paths = {
            "/lib64/pkgconfig",
            "/usr/lib64/pkgconfig",
            "/lib32/pkgconfig",
            "/usr/lib32/pkgconfig",
            "/lib/pkgconfig",
            "/usr/lib/pkgconfig",
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
        remove_file("/tmp/.empty.c");
        print_fn("\x1b[2K\r",false,true);
    }else if(get_bool("detect-dep")){
        foreach(string arg in args){
            info(colorize(_("Detect dependencies for:"),green)+" %s".printf(arg));
            string[] flist = {};
            if(iself(arg)){
                flist = detect_file_dep(arg);
            }else{
                flist = detect_dep(arg);
            }
            var deps = new array();
            foreach(string pkg in search_file(flist)){
                if(!deps.has(pkg)){
                    deps.add(pkg);
                }
            }
            print_array(deps.get());
        }
    }else{
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
    }
    return 0;
}

private string ldddata;
public void check(string file){
    print_fn("\x1b[2K\r"+_("Checking: %s").printf(sbasename(file)),false,true);
    ldddata = getoutput("ldd "+file+" 2>/dev/null");
    foreach(string line in ssplit(ldddata,"\n")){
        if(endswith(line,"not found")){
            print_fn("\x1b[2K\r",false,true);
            print(colorize(file,red) +" => "+ line[1:line.length-13]);
        }
    }
}
public void check_pkgconfig(string file){
    print_fn("\x1b[2K\r"+_("Checking: %s").printf(sbasename(file)),false,true);
    int status = run("gcc `pkg-config --cflags --libs "+file+" 2>/dev/null` /tmp/.empty.c -shared -o /dev/null 2>/dev/null");
    if(status != 0){
        print_fn("\x1b[2K\r",false,true);
        print(colorize(file,red)+" "+"broken.");
    }

}


public string[] detect_dep(string pkgname){
    if(!is_installed_package(pkgname)){
        error_add(_("%s is not an installed package.").printf(pkgname));
        return {};
    }
    var depfiles = new array();
    string files=readfile("%s/files/%s".printf(get_storage(), pkgname));
    foreach(string line in ssplit(files,"\n")){
        string path="/"+line[41:];
        if(iself(path)){
            foreach(string dep in detect_file_dep(path)){
                if(!depfiles.has(dep)){
                    depfiles.add(dep);
                }
            }
        }
    }
    return depfiles.get();
}

public string[] detect_file_dep(string path){
    if(!iself(path)){
        return {};
    }
    string lddout=getoutput("ldd '%s'".printf(path));
    var depfiles = new array();
    foreach(string ldline in ssplit(lddout,"\n")){
        if("=>" in ldline){
            string fdep = ldline.strip().split(" ")[2];
            if(!depfiles.has(fdep)){
                depfiles.add(fdep);
            }
        }
    }
    
    return depfiles.get();
}

void revdep_rebuild_init(){
    operation op = new operation();
    op.help = new helpmsg();
    op.callback.connect(revdep_rebuild_main);
    op.names = {_("revdep-rebuild"),"revdep-rebuild","rbd"};
    op.help.name = _("revdep-rebuild");
    op.help.description = _("Check library for broken links.");
    op.help.add_parameter("--pkgconfig",_("check pkgconfig files"));
    op.help.add_parameter("--detect-dep",_("detect package dependencies"));
    add_operation(op);
}
