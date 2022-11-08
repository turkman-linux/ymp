private bool no_src = false;
public int build_operation(string[] args){
    string[] new_args = args;
    if(new_args.length == 0){
        new_args = {"."};
    }
    foreach(string arg in new_args){
        if(!isfile(arg+"/ympbuild")){
            continue;
        }
        set_build_target(arg);
        if(!ympbuild_check()){
            error_add("ympbuild file is invalid!");
            error(2);
        }
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
    set_ympbuild_srcpath(src_path);
    string build_path = srealpath(get_build_dir()+calculate_md5sum(ympbuild_srcpath+"/ympbuild"));
    remove_all(build_path);
    set_ympbuild_buildpath(build_path);
    if(isdir(build_path)){
        remove_all(build_path);
    }
}

private void fetch_package_sources(){
    int i = 0;
    if(no_src){
        return;
    }
    string[] md5sums = get_ympbuild_array("md5sums");
    foreach(string src in get_ympbuild_array("source")){
        if(src == "" || md5sums[i] == ""){
            continue;
        }
        string srcfile = ympbuild_buildpath+"/"+sbasename(src);
        if(isfile(srcfile)){
            info("Source file already exists.");
        }else if(isfile(ympbuild_srcpath+"/"+src)){
            copy_file(ympbuild_srcpath+"/"+src, srcfile);
        }else{
            fetch(src,srcfile);
        }
        string md5 = calculate_md5sum(srcfile);
        if (md5sums[i] != md5 && md5sums[i] != "SKIP"){
            error_add("md5 check failed. Excepted: "+md5sums[i]+" <> Reveiced: "+md5);
        }
        i++;
    }
    error(2);
}

private void extract_package_sources(){
    cd(ympbuild_buildpath);
    var tar = new archive();
    foreach(string src in get_ympbuild_array("source")){
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
    print(colorize("Building package from:",yellow)+ympbuild_buildpath);
    cd(ympbuild_buildpath);
    int status = 0;
    if(!get_bool("no-build")){
        string[] build_actions = {"setup", "build"};
        foreach(string func in build_actions){
            info("Running build action: "+func);
            status = run_ympbuild_function(func);
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
            status = run_ympbuild_function(func);
            if(status != 0){
                error_add("Failed to build package. Action: "+func);
                error(status);
            }
        }
        ymp_process_binaries();
    }
    create_files_info();
}

private void create_source_archive(){
    debug("Create source package from :"+ympbuild_srcpath);
    cd(ympbuild_srcpath);
    string metadata = get_ympbuild_metadata();
    writefile(srealpath(ympbuild_buildpath+"/metadata.yaml"),metadata.strip()+"\n");
    var tar = new archive();
    tar.load(output_package_path+"_source.ymp");
    foreach(string file in find(ympbuild_srcpath)){
        if(!endswith(file,".ymp") && isfile(file)){
            file = file[(ympbuild_srcpath).length:];
            create_dir(sdirname(ympbuild_buildpath+"/"+file));
            copy_file(ympbuild_srcpath+file,ympbuild_buildpath+file);
        }
    }
    cd(ympbuild_buildpath);
    foreach(string file in find(ympbuild_buildpath)){
        file = file[(ympbuild_buildpath).length:];
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
    cd(ympbuild_buildpath+"/output");
    string files_data = "";
    string links_data = "";
    foreach(string file in find(ympbuild_buildpath+"/output")){
        if(" " in file){
            continue;
        }
        if(isdir(file)){
            continue;
        }
        if(issymlink(file)){
            try{
                file = file[(ympbuild_buildpath+"/output/").length:];
                string target = GLib.FileUtils.read_link(file);
                links_data += file+" "+target+"\n";
            }catch(Error e){
                warning(e.message);
            }
            continue;
        }
        file = file[(ympbuild_buildpath+"/output/").length:];
        if(file == "metadata.yaml"){
            continue;
        }
        debug("File info add: "+ file);
        files_data += calculate_sha1sum(file)+" "+file+"\n";
    }
    writefile(ympbuild_buildpath+"/output/files",files_data);
    writefile(ympbuild_buildpath+"/output/links",links_data);
}
private string output_package_path;
private void create_metadata_info(){
    string metadata = get_ympbuild_metadata();
    debug("Create metadata info: "+ympbuild_buildpath+"/output/metadata.yaml");
    var yaml = new yamlfile();
    yaml.data = metadata;
    string srcdata = yaml.get("ymp.source");
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
    string new_data = "ymp:\n";
    new_data += "  package:\n";
    string[] attrs = {"name", "version","release","description"};
    foreach(string attr in attrs){
        new_data += "    "+attr+": "+yaml.get_value(srcdata,attr)+"\n";
    }

    string[] arrys = {"depends","provides","replaces", "group"};
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
    output_package_path = ympbuild_srcpath+"/"+yaml.get_value(srcdata,"name")+"_"+yaml.get_value(srcdata,"version");
    writefile(ympbuild_buildpath+"/output/metadata.yaml",new_data);
}

private void create_data_file(){
    debug("Create data file: "+ympbuild_buildpath+"/output/data.tar.gz");
    var tar = new archive();
    tar.load(ympbuild_buildpath+"/output/data.tar.gz");
    aformat=1;
    afilter=1;
    int fnum = 0;
    foreach(string file in find(ympbuild_buildpath+"/output")){
        if(isdir(file)){
            continue;
        }
        file = file[(ympbuild_buildpath+"/output/").length:];
        debug("Compress:"+file);
        if(file == "files" || file == "links" || file == "metadata.yaml"){
            continue;
        }
        tar.add(file);
        fnum++;
    }
    if(isfile(ympbuild_buildpath+"/output/data.tar.gz")){
        remove_file(ympbuild_buildpath+"/output/data.tar.gz");
    }
    if(fnum != 0){
        tar.create();
    }
    string hash = calculate_sha1sum(ympbuild_buildpath+"/output/data.tar.gz");
    int size = filesize(ympbuild_buildpath+"/output/data.tar.gz");
    string new_data = readfile(ympbuild_buildpath+"/output/metadata.yaml");
    new_data += "    archive-hash: "+hash+"\n";
    new_data += "    arch: "+getArch()+"\n";
    new_data += "    archive-size: "+size.to_string()+"\n";
    writefile(ympbuild_buildpath+"/output/metadata.yaml",new_data);
    
}

private void create_binary_package(){
    debug("Create binary package from :"+ympbuild_buildpath);
    cd(ympbuild_buildpath+"/output");
    create_data_file();
    var tar = new archive();
    tar.load(output_package_path+"_"+getArch()+".ymp");
    if(isfile("data.tar.gz")){
        tar.add("data.tar.gz");
    }
    tar.add("metadata.yaml");
    tar.add("files");
    tar.add("links");
    if(isfile("icon.svg")){
        tar.add("icon.svg");
    }
    if(isfile(ympbuild_srcpath+"/postOps")){
        copy_file(ympbuild_srcpath+"/postOps","./postOps");
        tar.add("postOps");
    }
    tar.create();
}

void build_init(){
    var h = new helpmsg();
    h.name = "build";
    h.description = "Build package from ympbuild file.";
    h.add_parameter("--no-source", "do not generate source package");
    h.add_parameter("--no-binary", "do not generate binary package");
    h.add_parameter("--no-install","do not install package after building");
    h.add_parameter("--no-build","do not build package (only test and package)");
    h.add_parameter("--ignore-dependency", "disable dependency check");
    add_operation(build_operation,{"build","bi","make"},h);
}


