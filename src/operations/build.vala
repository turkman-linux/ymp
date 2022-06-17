public int build_operation(string[] args){
    var tar = new archive();
    foreach(string arg in args){
        set_pkgbuild_srcpath(arg);
        string build_path = srealpath(get_build_dir()+calculate_md5sum(pkgbuild_srcpath+"/PKGBUILD"));
        set_pkgbuild_buildpath(build_path);
        remove_all(build_path);
        cd(build_path);
        info("Building package from:"+build_path);
        foreach(string src in get_pkgbuild_array("source")){
            string srcfile = sbasename(src);
            fetch(src,srcfile);
            if(tar.is_archive(srcfile)){
                tar.load(srcfile);
                tar.extract_all();
            }
        }
        int status = 0;
        string[] build_actions = {"pkgver","prepare", "build"};
        foreach(string func in build_actions){
            info("Running build action: "+func);
            status = run_pkgbuild_function(func);
            if(status != 0){
                error_add("Failed to build package. Action: "+func);
                error(status);
            }
        }
    }
    return 0;
}

public void build_init(){
    add_operation(build_operation,{"build","bi"});
}
