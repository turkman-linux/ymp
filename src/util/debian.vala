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
    afilter=1; // gzip
    aformat=1; // tar
    data.create();
    cd(curdir);
    // update md5sums
    writefile(path+"/DEBIAN/md5sums",md5sum_data);
    // create control.tar.gz
    cd(path);
    var control = new archive();
    control.load(output+"/control.tar.gz");
    foreach(string file in find("DEBIAN")){
        control.add(file);
    }
    afilter=1; // gzip
    aformat=1; // tar
    control.create();
    writefile(output+"/debian-binary","2.0\n");
    cd(output);
    string target="%s/%s.deb".printf(output,sbasename(path));
    print(colorize(_("Creating debian package to:"),yellow)+" "+target);
    run("ar r '"+target+"' debian-binary control.tar.gz data.tar.gz");
    remove_file("debian-binary");
    remove_file("control.tar.gz");
    remove_file("data.tar.gz");
    cd(curdir);
    return 0;
}
