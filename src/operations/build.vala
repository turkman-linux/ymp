public int build_operation(string[] args){
    var tar = new archive();
    foreach(string arg in args){
        set_pkgbuild_srcpath(arg);
        string build_path = srealpath(get_build_dir()+calculate_md5sum(pkgbuild_srcpath+"/PKGBUILD"));
        set_pkgbuild_buildpath(build_path);
        remove_all(build_path);
        cd(build_path);
        create_source_archive();
        info("Building package from:"+build_path);
        foreach(string src in get_pkgbuild_array("source")){
            string srcfile = sbasename(src);
            if(!get_bool("no-download")){
                fetch(src,srcfile);
            }
            if(tar.is_archive(srcfile)){
                tar.load(srcfile);
                tar.extract_all();
            }
        }
        if(get_bool("no-build")){
            return 0;
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

public void create_source_archive(){
    string metadata = get_pkgbuild_metadata();
    writefile(srealpath(pkgbuild_srcpath+"/metadata.yaml"),metadata.strip());
    var tar = new archive();
    print(pkgbuild_srcpath+"/source.inary");
    tar.load(pkgbuild_srcpath+"/source.inary");
    tar.add("/etc/os-release");
    tar.create();
}

public void build_init(){
    add_operation(build_operation,{"build","bi"});
}


