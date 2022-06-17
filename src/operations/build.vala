public int build_operation(string[] args){
    foreach(string arg in args){
        set_pkgbuild_path(arg);
        print(get_pkgbuild_value("pkgname"));
        foreach(string src in get_pkgbuild_array("source")){
            print(src);
        }
    }
    return 0;
}

public void build_init(){
    add_operation(build_operation,{"build","bi"});
}
