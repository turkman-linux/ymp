public int build_operation(string[] args){
    var tar = new archive();
    foreach(string arg in args){
        set_inrbuild_srcpath(arg);
        string build_path = srealpath(get_build_dir()+calculate_md5sum(inrbuild_srcpath+"/INRBUILD"));
        set_inrbuild_buildpath(build_path);
        if(!get_bool("no-clear")){
            remove_all(build_path);
        }
        cd(inrbuild_srcpath);
        create_source_archive();
        cd(build_path);
        info("Building package from:"+build_path);
        foreach(string src in get_inrbuild_array("source")){
            if(src == ""){
                continue;
            }
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
            status = run_inrbuild_function(func);
            if(status != 0){
                error_add("Failed to build package. Action: "+func);
                error(status);
            }
        }
        if(get_bool("no-install")){
            return 0;
        }
        string[] install_actions = {"check","package"};
        foreach(string func in install_actions){
            info("Running build action: "+func);
            status = run_inrbuild_function(func);
            if(status != 0){
                error_add("Failed to build package. Action: "+func);
                error(status);
            }
        }
        create_binary_package();
    }
    return 0;
}

public void create_source_archive(){
    string metadata = get_inrbuild_metadata();
    writefile(srealpath(inrbuild_srcpath+"/metadata.yaml"),metadata.strip());
    var tar = new archive();
    print(inrbuild_srcpath+"/source.inary");
    tar.load(inrbuild_srcpath+"/source.inary");
    foreach(string file in listdir(".")){
        if(!endswith(file,".inary")){
            tar.add(file);
        }
    }
    tar.create();
}

public void create_binary_package(){
    info("Creating package:");
    cd(inrbuild_pkgdir+"/output");
    if(isfile("data.tar.gz")){
        remove_file("data.tar.gz");
    }
    if(isfile("metadata.yaml")){
        remove_file("metadata.yaml");
    }
    string metadata = get_inrbuild_metadata();
    var yaml = new yamlfile();
    yaml.data = metadata;
    string srcdata = yaml.get("inary.source");
    string new_data = "inary:\n";
    new_data += "  package:\n";
    string[] attrs = {"name", "version","release","description"};
    foreach(string attr in attrs){
        new_data += "    "+attr+": "+yaml.get_value(srcdata,attr)+"\n";
    }
    string[] arrys = {"depends","provides","replaces"};
    foreach(string arr in arrys){
        new_data += "    "+arr+":\n";
        foreach(string dep in yaml.get_array(srcdata,arr)){
            new_data += "      - "+dep+"\n";
        }
    }
    var tar = new archive();
    tar.load(inrbuild_pkgdir+"/output/data.tar.gz");
    aformat=1;
    afilter=1;
    foreach(string file in find(inrbuild_pkgdir+"/output")){
        if(isdir(file)){
            continue;
        }
        file = file[(inrbuild_pkgdir+"/output/").length:];
        debug("Compress:"+file);
        tar.add(file);
    }
    if(isfile(inrbuild_pkgdir+"/output/data.tar.gz")){
        remove_file(inrbuild_pkgdir+"/output/data.tar.gz");
    }
    tar.create();
    string hash = calculate_sha1sum(inrbuild_pkgdir+"/output/data.tar.gz");
    int size = filesize(inrbuild_pkgdir+"/output/data.tar.gz");
    new_data += "    archive-hash: "+hash+"\n";
    new_data += "    archive-size: "+size.to_string()+"\n";
    
    tar = new archive();
    tar.load(inrbuild_srcpath+"/"+yaml.get_value(srcdata,"name")+"_"+yaml.get_value(srcdata,"version")+"_"+getArch()+".inary");
    tar.add("data.tar.gz");
    tar.add("metadata.yaml");
    writefile("metadata.yaml",new_data);
    if(isfile(inrbuild_srcpath+"/postOps")){
        copy_file(inrbuild_srcpath+"/postOps","./postOps");
        tar.add("postOps");
    }
    tar.create();
    
}

public void build_init(){
    add_operation(build_operation,{"build","bi"});
}


