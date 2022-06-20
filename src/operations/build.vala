public int build_operation(string[] args){
    var tar = new archive();
    foreach(string arg in args){
        set_inrbuild_srcpath(arg);
        string build_path = srealpath(get_build_dir()+calculate_md5sum(inrbuild_srcpath+"/INRBUILD"));
        set_inrbuild_buildpath(build_path);
        if(!get_bool("no-clear")){
            remove_all(inrbuild_buildpath);
        }
        build_package();
        create_source_archive();
        create_binary_package();
    }
    return 0;
}

private void build_package(){
    cd(inrbuild_buildpath);
    info("Building package from:"+inrbuild_buildpath);
    var tar = new archive();
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
        return;
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
        return;
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
    create_metadata_info();
    create_files_info();
}

private void create_source_archive(){
    cd(inrbuild_srcpath);
    string metadata = get_inrbuild_metadata();
    writefile(srealpath(inrbuild_srcpath+"/metadata.yaml"),metadata.strip());
    var tar = new archive();
    print(inrbuild_srcpath+"/source.inary");
    tar.load(output_package_path+"source.inary");
    foreach(string file in listdir(".")){
        if(!endswith(file,".inary")){
            tar.add(file);
        }
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
        files_data += calculate_sha1sum(file)+" "+file+"\n";
    }
    writefile("files",files_data);
}
private string output_package_path;
private void create_metadata_info(){
    cd(inrbuild_buildpath+"/output");
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
    output_package_path = inrbuild_srcpath+"/"+yaml.get_value(srcdata,"name")+"_"+yaml.get_value(srcdata,"version")+"_"+getArch();
    writefile("metadata.yaml",new_data);
}

private void create_data_file(){
    cd(inrbuild_buildpath+"/output");
    var tar = new archive();
    tar.load(inrbuild_buildpath+"/output/data.tar.gz");
    aformat=1;
    afilter=1;
    foreach(string file in find(inrbuild_buildpath+"/output")){
        if(isdir(file)){
            continue;
        }
        file = file[(inrbuild_buildpath+"/output/").length:];
        debug("Compress:"+file);
        tar.add(file);
    }
    if(isfile(inrbuild_buildpath+"/output/data.tar.gz")){
        remove_file(inrbuild_buildpath+"/output/data.tar.gz");
    }
    tar.create();
    string hash = calculate_sha1sum(inrbuild_buildpath+"/output/data.tar.gz");
    int size = filesize(inrbuild_buildpath+"/output/data.tar.gz");
    string new_data = readfile("metadata.yaml");
    new_data += "    archive-hash: "+hash+"\n";
    new_data += "    archive-size: "+size.to_string()+"\n";
    writefile("metadata.yaml",new_data);
    
}

private void quarantine_install_binary(){

}

private void create_binary_package(){
    cd(inrbuild_buildpath+"/output");
    create_data_file();
    var tar = new archive();
    tar.load(output_package_path+".inary");
    tar.add("data.tar.gz");
    tar.add("metadata.yaml");
    tar.add("files");
    if(isfile(inrbuild_srcpath+"/postOps")){
        copy_file(inrbuild_srcpath+"/postOps","./postOps");
        tar.add("postOps");
    }
    tar.create();
}

public void build_init(){
    add_operation(build_operation,{"build","bi"});
}


