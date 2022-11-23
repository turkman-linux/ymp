private bool no_src = false;
public int build_operation(string[] args){
    string currend_directory=srealpath(pwd());
    string[] new_args = args;
    if(usr_is_merged()){
        error_add("Build operation with usrmerge is not allowed!");
        error(31);
    }
    if(new_args.length == 0){
        new_args = {"."};
    }
    foreach(string arg in new_args){
        string srcpath=arg;
        if(startswith(arg,"git://") || endswith(arg,".git")){
            srcpath=DESTDIR+"/tmp/ymp-build/"+sbasename(arg);
            if(run("git clone '"+arg+"' "+srcpath) != 0){
                error_add("Failed to fetch git package.");
                return 2;
            }
        }else if(startswith(arg,"http://") || startswith(arg,"https://")){
            string file=DESTDIR+"/tmp/ymp-build/.cache/"+sbasename(arg);
            create_dir(file);
            string farg = file+"/"+sbasename(arg);
            if(!isfile(farg)){
                fetch(arg,farg);
            }
            arg=farg;
            srcpath=farg;
        }
        if(isfile(srcpath)){
            srcpath = DESTDIR+"/tmp/ymp-build/"+calculate_md5sum(srcpath);
            var tar = new archive();
            tar.load(arg);
            tar.set_target(srcpath);
            tar.extract_all();
            if(!isfile(srcpath+"/ympbuild")){
                error_add("Package is invalid");
                remove_all(srcpath);
                return 2;
            }
        }
        if(!isfile(srcpath+"/ympbuild")){
            continue;
        }
        if(!set_build_target(srcpath)){
            return 1;
        }
        if(!create_metadata_info()){
            return 1;
        }
        if(!check_build_dependencies(new_args)){
            return 1;
        }
        if(!fetch_package_sources()){
            return 2;
        }
        if(! isfile(arg) && !get_bool("no-source")){
            if(!create_source_archive()){
                return 1;
            }
        }
        if(!get_bool("no-binary")){
            if(!extract_package_sources()){
                return 3;
            }
            if(isfile(arg)){
                var fname = sbasename(output_package_path);
                output_package_path=currend_directory+"/"+fname;
            }
            if(!build_package()){
                return 1;
            }
            create_binary_package();
            if(get_bool("install")){
                if(0 != install_main({output_package_path+"_"+getArch()+".ymp"})){
                    return 1;
                }
            }
        }
    }
    cd(currend_directory);
    return 0;
}

private bool check_build_dependencies(string[] args){
    if(get_bool("ignore-dependency")){
        return true;
    }
    string metadata = get_ympbuild_metadata();
    var yaml = new yamlfile();
    yaml.data = metadata;
    yaml.data = yaml.get("ymp.source");
    var deps = new array();
    deps.adds(yaml.get_array(yaml.data,"makedepends"));
    deps.adds(yaml.get_array(yaml.data,"depends"));
    string name = yaml.get_value(yaml.data,"name");
    string[] use_flags = ssplit(get_value("use")," ");
    string package_use = get_config("package.use",name);
    if(package_use.length > 0){
        use_flags = ssplit(package_use," ");
    }
    if("all" in use_flags){
        use_flags=yaml.get_array(yaml.data,"use-flags");
    }
    foreach(string flag in use_flags){
        deps.adds(yaml.get_array(yaml.data,flag+"-depends"));
    }
    string[] pkgs = resolve_dependencies(deps.get());
    string[] need_install = {};
    foreach(string pkg in pkgs){
        info(join(" ",pkgs));
        if(pkg in args || pkg == name){
            continue;
        }else if(is_installed_package(pkg)){
            continue;
        }else{
            need_install += pkg;
        }
    }
    if(need_install.length > 0){
        error_add("Packages is not installed: "+join(" ",need_install));
    }
    return (!has_error());
}

private bool set_build_target(string src_path){
    set_ympbuild_srcpath(src_path);
    string build_path = srealpath(get_build_dir()+calculate_md5sum(ympbuild_srcpath+"/ympbuild"));
    remove_all(build_path);
    set_ympbuild_buildpath(build_path);
    if(isdir(build_path)){
        remove_all(build_path);
    }
    if(!ympbuild_check()){
        error_add("ympbuild file is invalid!");
        return false;
    }
    return true;
}

private bool fetch_package_sources(){
    int i = 0;
    if(no_src){
        return true;
    }
    string[] md5sums = get_ympbuild_array("md5sums");
    foreach(string src in get_ympbuild_array("source")){
        if(src == "" || md5sums[i] == ""){
            continue;
        }
        string srcfile = ympbuild_buildpath+"/"+sbasename(src);
        string ymp_source_cache = DESTDIR+"/tmp/ymp-build/.cache/"+get_ympbuild_value("name")+"/";
        create_dir(ymp_source_cache);
        if(isfile(srcfile)){
            info("Source file already exists.");
        }else if(isfile(ymp_source_cache+"/"+sbasename(src))){
            info("Source file import from cache.");
            copy_file(ymp_source_cache+"/"+sbasename(src), srcfile);
        }else if(isfile(ympbuild_srcpath+"/"+src)){
            copy_file(ympbuild_srcpath+"/"+src, srcfile);
        }else{
            info("Download: "+src);
            fetch(src,ymp_source_cache+"/"+sbasename(src));
            copy_file(ymp_source_cache+"/"+sbasename(src), srcfile);
        }
        string md5 = calculate_md5sum(srcfile);
        if (md5sums[i] != md5 && md5sums[i] != "SKIP"){
            remove_all(ymp_source_cache+"/"+sbasename(src));
            error_add("md5 check failed. Excepted: "+md5sums[i]+" <> Reveiced: "+md5);
        }
        i++;
    }
    return (!has_error());
}

private bool extract_package_sources(){
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
    return true;
}

private bool build_package(){
    print(colorize("Building package from:",yellow)+ympbuild_buildpath);
    cd(ympbuild_buildpath);
    int status = 0;
    if(!get_bool("no-build")){
        string[] build_actions = {"prepare","setup", "build"};
        foreach(string func in build_actions){
            info("Running build action: "+func);
            status = run_ympbuild_function(func);
            if(status != 0){
                error_add("Failed to build package. Action: "+func);
                return false;
            }
        }
    }
    if(!get_bool("no-package")){
        string[] install_actions = {"test","package"};
        foreach(string func in install_actions){
            info("Running build action: "+func);
            status = run_ympbuild_function(func);
            if(status != 0){
                error_add("Failed to build package. Action: "+func);
                return false;
            }
        }
        ymp_process_binaries();
    }
    create_files_info();
    return true;
}

private bool create_source_archive(){
    print(colorize("Create source package from :",yellow)+ympbuild_srcpath);
    cd(ympbuild_srcpath);
    string metadata = get_ympbuild_metadata();
    writefile(srealpath(ympbuild_buildpath+"/metadata.yaml"),metadata.strip()+"\n");
    var tar = new archive();
    tar.load(ympbuild_buildpath+"/source.zip");
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
    move_file(ympbuild_buildpath+"/source.zip",output_package_path+"_source.ymp");
    return true;
}

private bool create_files_info(){
    cd(ympbuild_buildpath+"/output");
    string files_data = "";
    string links_data = "";
    foreach(string path in listdir(ympbuild_buildpath+"/output")){
        if(path == "metadata.yaml" || path == "icon.svg"){
            continue;
        }
        string fpath = ympbuild_buildpath+"/output/"+path;
        if(issymlink(fpath)){
            continue;
        }else if(isfile(fpath)){
            error_add("Files are not allowed in root directory: /"+path);
        }
    }
    foreach(string file in find(ympbuild_buildpath+"/output")){
        if(" " in file){
            continue;
        }
        if(isdir(file)){
            continue;
        }
        if(filesize(file)==0){
            warning("Empty file detected: "+file);
        }
        if(issymlink(file)){
            var link = sreadlink(file);
            if(!isexists(sdirname(file)+"/"+link) && link.length > 0){
                error_add("Broken symlink detected:\n"+file+" => "+link);
                continue;
            }
            file = file[(ympbuild_buildpath+"/output/").length:];
            debug("Link info add: "+ file);
            links_data += file+" "+link+"\n";
            continue;
        }else{
            file = file[(ympbuild_buildpath+"/output/").length:];
            if(file == "metadata.yaml" || file == "icon.svg"){
                continue;
            }
            debug("File info add: "+ file);
            files_data += calculate_sha1sum(file)+" "+file+"\n";
        }
    }
    if(has_error()){
        return false;
    }
    writefile(ympbuild_buildpath+"/output/files",files_data);
    writefile(ympbuild_buildpath+"/output/links",links_data);
    return true;
}
private string output_package_path;
private bool create_metadata_info(){
    string metadata = get_ympbuild_metadata();
    debug("Create metadata info: "+ympbuild_buildpath+"/output/metadata.yaml");
    var yaml = new yamlfile();
    yaml.data = metadata;
    string srcdata = yaml.get("ymp.source");
    string name = yaml.get_value(srcdata,"name");
    string release = yaml.get_value(srcdata,"release");
    string version = yaml.get_value(srcdata,"version");
    if(get_bool("ignore-dependency")){
        warning("Dependency check disabled");
    }else{
        if(yaml.has_area(srcdata,"depends")){
            foreach(string dep in yaml.get_array(srcdata,"depends")){
                if(!is_installed_package(dep)){
                    error_add("Package "+dep+" in not satisfied. Required by: "+name);
                }
            }
        }
        if(yaml.has_area(srcdata,"makedepends")){
            foreach(string dep in yaml.get_array(srcdata,"makedepends")){
                if(!is_installed_package(dep)){
                    error_add("Package "+dep+" in not satisfied. Required by: "+name);
                }
            }
        }
        if(has_error()){
            return false;
        }
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

    string[] arrys = {"provides","replaces", "group"};
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
    // calculate dependency list by use flag and base dependencies
    var deps = new array();
    if(yaml.has_area(srcdata,"depends")){
        deps.adds(yaml.get_array(srcdata,"depends"));
    }
    string[] use_flags = ssplit(get_value("use")," ");
    string package_use = get_config("package.use",name);
    if(package_use.length > 0){
        use_flags = ssplit(package_use," ");
    }
    if("all" in use_flags){
        use_flags = yaml.get_array(srcdata,"use-flags");
    }
    if(yaml.has_area(srcdata,"use-flags")){
        foreach(string flag in use_flags){
            info("Add use flag dependency: "+flag);
            string[] fdeps = yaml.get_array(srcdata,flag+"-depends");
            if(fdeps.length > 0){
                deps.adds(fdeps);
            }
        }
    }
    if(deps.length() > 0){
        new_data += "    depends:\n";
        foreach(string dep in deps.get()){
            new_data += "      - "+dep+"\n";
        }
    }
    if(release == ""){
        error_add("Release is not defined.");
    }
    if(version == ""){
        error_add("Version is not defined.");
    }
    if(name == ""){
        error_add("Name is not defined.");
    }
    if(has_error()){
        return false;
    }
    output_package_path = ympbuild_srcpath+"/"+name+"_"+version+"_"+release;
    writefile(ympbuild_buildpath+"/output/metadata.yaml",new_data);
    return true;
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
        if(file == "files" || file == "links" || file == "metadata.yaml"|| file == "icon.svg"){
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
    print(colorize("Create binary package from :",yellow)+ympbuild_buildpath);
    cd(ympbuild_buildpath+"/output");
    create_data_file();
    var tar = new archive();
    tar.load(ympbuild_buildpath+"/package.zip");
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
    move_file(ympbuild_buildpath+"/package.zip",output_package_path+"_"+getArch()+".ymp");
}

void build_init(){
    var h = new helpmsg();
    h.name = "build";
    h.description = "Build package from ympbuild file.";
    h.add_parameter("--no-source", "do not generate source package");
    h.add_parameter("--no-binary", "do not generate binary package");
    h.add_parameter("--no-build","do not build package (only test and package)");
    h.add_parameter("--no-package","do not install package after building");
    h.add_parameter("--ignore-dependency", "disable dependency check");
    h.add_parameter("--no-emerge", "use binary packages");
    h.add_parameter("--install", "install binary package after building");
    add_operation(build_operation,{"build","bi","make"},h);
}


