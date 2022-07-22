private bool no_src = false;
public int build_operation(string[] args){
    string[] new_args = args;
    if(new_args.length == 0){
        new_args = {"."};
    }
    foreach(string arg in new_args){
        if(!isfile(arg+"/INRBUILD")){
            continue;
        }
        set_build_target(arg);
        create_metadata_info();
        fetch_package_sources();
        if(!get_bool("no-source")){
            create_source_archive();
        }
        if(!get_bool("no-binary")){
            extract_package_sources();
            build_package();
            create_binary_package();
        }
    }
    return 0;
}

private void set_build_target(string src_path){
    set_inrbuild_srcpath(src_path);
    string build_path = srealpath(get_build_dir()+calculate_md5sum(inrbuild_srcpath+"/INRBUILD"));
    set_inrbuild_buildpath(build_path);
    if(isdir(build_path)){
        remove_all(build_path);
    }
}

private void fetch_package_sources(){
    int i = 0;
    if(no_src){
        return;
    }
    string[] md5sums = get_inrbuild_array("md5sums");
    foreach(string src in get_inrbuild_array("source")){
        if(src == "" || md5sums[i] == ""){
            continue;
        }
        string srcfile = inrbuild_buildpath+"/"+sbasename(src);
        fetch(src,srcfile);
        string md5 = calculate_md5sum(srcfile);
        if (md5sums[i] != md5 && md5sums[i] != "SKIP"){
            error_add("md5 check failed. Excepted: "+md5sums[i]+" <> Reveiced: "+md5);
        }
        i++;
    }
    error(2);
}

private void extract_package_sources(){
    cd(inrbuild_buildpath);
    var tar = new archive();
    foreach(string src in get_inrbuild_array("source")){
        if(src == ""){
            continue;
        }
        string srcfile = sbasename(src);
        if(tar.is_archive(srcfile)){
            tar.load(srcfile);
            tar.extract_all();
        }
    }
}

private void build_package(){
    info("Building package from:"+inrbuild_buildpath);
    cd(inrbuild_buildpath);
    int status = 0;
    if(!get_bool("no-build")){
        string[] build_actions = {"setup", "build"};
        foreach(string func in build_actions){
            info("Running build action: "+func);
            status = run_inrbuild_function(func);
            if(status != 0){
                error_add("Failed to build package. Action: "+func);
                error(status);
            }
        }
    }
    if(!get_bool("no-install")){
        string[] install_actions = {"test","package"};
        foreach(string func in install_actions){
            info("Running build action: "+func);
            status = run_inrbuild_function(func);
            if(status != 0){
                error_add("Failed to build package. Action: "+func);
                error(status);
            }
        }
        inary_process_binaries();
    }
    create_files_info();
}

private void create_source_archive(){
    debug("Create source package from :"+inrbuild_srcpath);
    cd(inrbuild_srcpath);
    string metadata = get_inrbuild_metadata();
    writefile(srealpath(inrbuild_buildpath+"/metadata.yaml"),metadata.strip());
    var tar = new archive();
    tar.load(output_package_path+"_source.inary");
    foreach(string file in find(inrbuild_srcpath)){
        if(!endswith(file,".inary") && isfile(file)){
            file = file[(inrbuild_srcpath).length:];
            create_dir(sdirname(inrbuild_buildpath+"/"+file));
            copy_file(inrbuild_srcpath+file,inrbuild_buildpath+file);
        }
    }
    cd(inrbuild_buildpath);
    foreach(string file in find(inrbuild_buildpath)){
        file = file[(inrbuild_buildpath).length:];
        if(file[0] == '/'){
            file = file[1:];
        }
        if(file == null || file == "" || startswith(file,"output")){
            continue;
        }
        tar.add(file);
    }
    tar.create();
}

private void create_files_info(){
    cd(inrbuild_buildpath+"/output");
    string files_data = "";
    foreach(string file in find(inrbuild_buildpath+"/output")){
        if(isdir(file)){
            continue;
        }
        file = file[(inrbuild_buildpath+"/output/").length:];
        if(file == "metadata.yaml"){
            continue;
        }
        debug("File info add: "+ file);
        files_data += calculate_sha1sum(file)+" "+file+"\n";
    }
    writefile(inrbuild_buildpath+"/output/files",files_data);
}
private string output_package_path;
private void create_metadata_info(){
    string metadata = get_inrbuild_metadata();
    debug("Create metadata info: "+inrbuild_buildpath+"/output/metadata.yaml");
    var yaml = new yamlfile();
    yaml.data = metadata;
    string srcdata = yaml.get("inary.source");
    if(get_bool("ignore-dependency")){
        warning("Dependency check disabled");
    }else{
        if(yaml.has_area(srcdata,"depends")){
            foreach(string dep in yaml.get_array(srcdata,"depends")){
                if(!is_installed_package(dep)){
                    error_add("Package "+dep+" in not satisfied. Required by: "+yaml.get_value(srcdata,"name"));
                }
            }
        }
        if(yaml.has_area(srcdata,"makedepends")){
            foreach(string dep in yaml.get_array(srcdata,"makedepends")){
                if(!is_installed_package(dep)){
                    error_add("Package "+dep+" in not satisfied. Required by: "+yaml.get_value(srcdata,"name"));
                }
            }
        }
        error(2);
    }
    no_src = false;
    if(!yaml.has_area(srcdata,"archive")){
        no_src = true;
        warning("Source array not defined");
    }
    string new_data = "inary:\n";
    new_data += "  package:\n";
    string[] attrs = {"name", "version","release","description"};
    foreach(string attr in attrs){
        new_data += "    "+attr+": "+yaml.get_value(srcdata,attr)+"\n";
    }

    string[] arrys = {"depends","provides","replaces"};
    foreach(string arr in arrys){
        if(!yaml.has_area(srcdata,arr)){
            continue;
        }
        string[] deps = yaml.get_array(srcdata,arr);
        if(deps.length > 0){
            new_data += "    "+arr+":\n";
            foreach(string dep in deps){
                new_data += "      - "+dep+"\n";
            }
        }
    }
    output_package_path = inrbuild_srcpath+"/"+yaml.get_value(srcdata,"name")+"_"+yaml.get_value(srcdata,"version");
    writefile(inrbuild_buildpath+"/output/metadata.yaml",new_data);
}

private void create_data_file(){
    debug("Create data file: "+inrbuild_buildpath+"/output/data.tar.gz");
    var tar = new archive();
    tar.load(inrbuild_buildpath+"/output/data.tar.gz");
    aformat=1;
    afilter=1;
    int fnum = 0;
    foreach(string file in find(inrbuild_buildpath+"/output")){
        if(isdir(file)){
            continue;
        }
        file = file[(inrbuild_buildpath+"/output/").length:];
        debug("Compress:"+file);
        if(file == "files" || file == "metadata.yaml"){
            continue;
        }
        tar.add(file);
        fnum++;
    }
    if(isfile(inrbuild_buildpath+"/output/data.tar.gz")){
        remove_file(inrbuild_buildpath+"/output/data.tar.gz");
    }
    if(fnum != 0){
        tar.create();
    }
    string hash = calculate_sha1sum(inrbuild_buildpath+"/output/data.tar.gz");
    int size = filesize(inrbuild_buildpath+"/output/data.tar.gz");
    string new_data = readfile(inrbuild_buildpath+"/output/metadata.yaml");
    new_data += "    archive-hash: "+hash+"\n";
    new_data += "    arch: "+getArch()+"\n";
    new_data += "    archive-size: "+size.to_string()+"\n";
    writefile(inrbuild_buildpath+"/output/metadata.yaml",new_data);
    
}

private void create_binary_package(){
    debug("Create binary package from :"+inrbuild_buildpath);
    cd(inrbuild_buildpath+"/output");
    create_data_file();
    var tar = new archive();
    tar.load(output_package_path+"_"+getArch()+".inary");
    if(isfile("data.tar.gz")){
        tar.add("data.tar.gz");
    }
    tar.add("metadata.yaml");
    tar.add("files");
    if(isfile(inrbuild_srcpath+"/postOps")){
        copy_file(inrbuild_srcpath+"/postOps","./postOps");
        tar.add("postOps");
    }
    tar.create();
}

void build_init(){
    add_operation(build_operation,{"build","bi","make"});
}


