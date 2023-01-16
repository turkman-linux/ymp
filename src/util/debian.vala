//DOC: `int deb_extract(string file, string output):`
//DOC: extract debian packages
public int deb_extract(string debfile, string output){
    create_dir(output);
    var deb = new archive();
    deb.load(debfile);
    deb.set_target(output);
    foreach(string file in deb.list_files()){
        if(startswith(file,"data.tar.")){
            deb.extract(file);
            var data = new archive();
            data.load(output+"/"+file);
            data.set_target(output);
            data.extract_all();
            remove_file(output+"/"+file);
        }else if(startswith(file,"control.tar.")){
            deb.extract(file);
            var control = new archive();
            control.load(output+"/"+file);
            control.set_target(output+"/DEBIAN");
            control.extract_all();
            remove_file(output+"/"+file);
            remove_file(output+"/DEBIAN/md5sums");
        }
    }
    return 0;
}

public int deb_create(string fpath, string output){
    // create data.tar.gz
    var data = new archive();
    string path = srealpath(fpath);
    data.load(output+"/data.tar.gz");
    string curdir = pwd();
    cd(path);
    string md5sum_data = "";
    foreach(string dir in listdir("./")){
        if(startswith(dir,"DEBIAN")){
            continue;
        }
        foreach(string file in find(dir)){
            if(isfile(file) && ! issymlink(file)){
                string md5 = calculate_md5sum(path+"/"+file);
                md5sum_data += "%s  %s\n".printf(md5, file);
            }
            data.add(file);
        }
    }
    set_archive_type("tar","gzip");
    data.create();
    cd(curdir);
    // update md5sums
    writefile(path+"/DEBIAN/md5sums",md5sum_data);
    // create control.tar.gz
    cd(path+"/DEBIAN");
    var control = new archive();
    control.load(output+"/control.tar.gz");
    foreach(string file in listdir(".")){
        control.add(file);
    }
    set_archive_type("tar","gzip");
    control.create();
    writefile(output+"/debian-binary","2.0\n");
    cd(output);
    string target="%s/%s.deb".printf(output,sbasename(path));
    print(colorize(_("Creating debian package to:"),yellow)+" "+target);
    var debfile = new archive();
    debfile.load(target);
    debfile.add("debian-binary");
    debfile.add("control.tar.gz");
    debfile.add("data.tar.gz");
    set_archive_type("ar","none");
    debfile.create();
    remove_file("debian-binary");
    remove_file("control.tar.gz");
    remove_file("data.tar.gz");
    cd(curdir);
    return 0;
}

public int debian_update_catalog(){
    string mirror = "https://ftp.debian.org/debian/";
    if(get_value("mirror") != ""){
        mirror = get_value("mirror");
    }
    fetch(mirror+"/dists/unstable/main/source/Sources.gz","/tmp/.debian-catalog.gz");
    if(isfile("/tmp/.debian-catalog")){
        remove_file("/tmp/.debian-catalog");
    }
    if (0 != run("gzip -d /tmp/.debian-catalog.gz")){
        error_add(_("Failed to decompress debian index."));
    }
    string data = readfile_raw("/tmp/.debian-catalog");
    string src="";
    string fdata = "";
    foreach(string line in ssplit(data,"\n")){
       if(startswith(line,"Package:")){
           src=line[8:];
       }else if(startswith(line,"Binary:")){
           fdata += "%s : %s \n".printf(
               src.strip(),
               line[7:].replace(", "," ").replace("/","").strip()
           );
       }
    }
    create_dir(get_storage()+"/debian/");
    writefile(get_storage()+"/debian/catalog",fdata);
    remove_file("/tmp/.debian-catalog");
    return 0;
}

private string[] catalog_cache = null;
public string find_debian_pkgname_from_catalog(string name){
    if(catalog_cache == null){
        catalog_cache = ssplit(readfile_raw(get_storage()+"/debian/catalog"),"\n");
    }
    foreach(string line in catalog_cache){
        if(name+" " in line){
            return ssplit(line,":")[0].strip();
        }
    }
    return "";
}
