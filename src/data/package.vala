//DOC: ## class package
//DOC: inary package struct & functions
//DOC: Example usage:
//DOC: ```vala
//DOC: var pkg = new package();
//DOC: pkg.load_from_archive("/tmp/bash-5.0-x86_64.inary");
//DOC: stdout.printf(pkg.get("archive-hash"));
//DOC: foreach(string pkgname in pkg.dependencies){
//DOC:     stdout.printf(pkgname);
//DOC: }
//DOC: var pkg2 = new package();
//DOC: pkg2.load("/tmp/metadata.yaml");
//DOC: if(pkg2.is_installed()){
//DOC:     stdout.printf(pkg2+" installed");
//DOC: }
//DOC: ```
public class package {
    private yamlfile yaml;
    public string name;
    public string version;
    public string[] dependencies;
    public int release;
    public bool is_source;
    public string repo_address;
    private string pkgarea;
    private archive pkgfile;

    //DOC: `void package.load(string path):`
    //DOC: Read package information from metadata file
    public void load(string path){
        load_from_data(readfile(path));
        read_values();
    }

    //DOC: `void package.load_from_data(string data):`
    //DOC: Read package information from string data
    public void load_from_data(string metadata){
        yaml = new yamlfile();
        if(yaml.has_area(metadata,"inary")){
            string inarydata = yaml.get_area(metadata,"inary");
            if(yaml.has_area(inarydata,"package")){
                is_source = false;
                pkgarea = yaml.get_area(inarydata,"package");
            }else if(yaml.has_area(inarydata,"source")){
                is_source = true;
                pkgarea = yaml.get_area(inarydata,"source");
            }else{
                error_add("Package is broken");
            }
        }else{
            error_add("Package is broken");
        }
        read_values();
    }

    //DOC: `void package.load_from_archive(string path):`
    //DOC: Read package information from inary file
    public void load_from_archive(string path){
        pkgfile = new archive();
        pkgfile.load(path);
        var metadata = pkgfile.readfile("metadata.yaml");
        load_from_data(metadata);
    }

    //DOC: `string[] package.list_files():`
    //DOC: return inary package files list
    public string[] list_files(){
        if(is_source){
            return readfile(inrbuild_buildpath+"/output/files").split("\n");
        }
        if(pkgfile == null){
            if(is_installed_package(name)){
                string files = readfile(get_storage()+"/files/"+name);
                return ssplit(files,"\n");
            }
            error_add("Package archive missing");
            return {};
        }
        string files = pkgfile.readfile("files");
        return ssplit(files,"\n");
    }

    private void read_values(){
        name = get("name");
        version = get("version");
        dependencies = gets("dependencies");
        release = int.parse(get("release"));
    }

    //DOC: `string[] package.gets(string name):`
    //DOC: Get package array value
    public string[] gets(string name){
        if (yaml.has_area(pkgarea,name)){
            return yaml.get_array(pkgarea,name);
        }
        return {};
    }

    //DOC: `string package.get(string name):`
    //DOC: Get package value
    public string get(string name){
        if (yaml.has_area(pkgarea,name)){
            debug(@"Package data: $name");
            return yaml.get_value(pkgarea,name);
        }
        warning(@"Package information broken: $name");
        return "";
    }

    //DOC: `string package.get_uri():`
    //DOC: get repository uri
    public string get_uri(){
        if(repo_address == null){
            return "";
        }
        return repo_address + "/" + get("uri");
    }


	//DOC: `void package.download():`
	//DOC: download package file from repository
    public void download(){
		if(get_uri() != ""){
	        if(!fetch(get_uri(),get_storage()+"/packages/"+sbasename(get_uri()))){
                error_add("failed to fetch package: "+get_uri());
            }
	    }else{
			error_add("package is not downloadable: "+ name);
		}
        pkgfile = new archive();
        pkgfile.load(get_storage()+"/packages/"+sbasename(get_uri()));
	}

    //DOC: `void package.extract():`
    //DOC: extract package to quarantine directory
    //DOC: quarantine directory is **get_storage()+"/quarantine"**;
    //DOC: Example inary archive format:
    //DOC: ```yaml
    //DOC: package.inary
    //DOC:   ├── data.tar.gz
    //DOC:   │     ├ /usr
    //DOC:   │     │  └ ...
    //DOC:   │     └ /etc
    //DOC:   │        └ ...
    //DOC:   ├── files
    //DOC:   └── metadata.yaml
    //DOC: ```
    //DOC: * **metadata.yaml** file is package information data.
    //DOC: * **files** is file list
    //DOC: * **data.tar.gz** in package archive
    public void extract(){
        create_dir(get_storage()+"/quarantine/metadata");
        create_dir(get_storage()+"/quarantine/rootfs");
        create_dir(get_storage()+"/quarantine/files");
        if(pkgfile == null){
            error_add("Package archive missing");
            return;
        }
        if(is_source){
            string curdir = pwd();
            create_dir(DESTDIR+"/tmp/inary-build/"+name);
            pkgfile.set_target(DESTDIR+"/tmp/inary-build/"+name);
            pkgfile.extract_all();
            set_build_target(DESTDIR+"/tmp/inary-build/"+name);
            fetch_package_sources();
            extract_package_sources();
            create_metadata_info();
            build_package();
            quarantine_import_from_path(inrbuild_buildpath+"/output");
            cd(curdir);
            return;
        }
        var rootfs_medatata = get_storage()+"/quarantine/metadata/";
        var rootfs_files = get_storage()+"/quarantine/files/";
        if(isfile(rootfs_medatata+name+".yaml")){
            debug("skip quartine package extract:"+name);
            return;
        }
        // extract data archive
        pkgfile.set_target(get_storage()+"/quarantine");
        foreach (string data in pkgfile.list_files()){
            // Allowed formats: data.tar.xz data.zip data.tar.zst data.tar.gz ..
            if(startswith(data,"data.")){
                // 1. data.* file extract to quarantine from inary package
                pkgfile.extract(data);
                var datafile = get_storage()+"/quarantine/"+data;
                // 2. data.* package extract to quarantine/rootfs
                var file_archive = new archive();
                file_archive.load(datafile);
                file_archive.set_target(get_storage()+"/quarantine/rootfs");
                file_archive.extract_all();
                // 3. remove data.* file
                remove_file(datafile);
                break;
            }
        }
        // extract metadata
        if(isfile(rootfs_medatata+"metadata.yaml")){
            remove_file(rootfs_medatata+"metadata.yaml");
        }
        pkgfile.set_target(rootfs_medatata);
        pkgfile.extract("metadata.yaml");
        move_file(rootfs_medatata+"metadata.yaml",get_storage()+"/quarantine/metadata/"+name+".yaml");
        // extract files
        pkgfile.set_target(rootfs_files);
        pkgfile.extract("files");
        move_file(rootfs_files+"files",get_storage()+"/quarantine/files/"+name);
        error(3);
    }

    //DOC: `bool package.is_installed():`
    //DOC: return true if package is installed
    public bool is_installed(){
        return is_installed_package(name);
    }
}

//DOC: ## Miscellaneous package functions
//DOC: package functions outside package class

//DOC: `string[] list_installed_packages():`
//DOC: return installed package names array
public string[] list_installed_packages(){
    string[] pkgs = {};
    foreach(string fname in listdir(get_storage()+"/metadata")){
        pkgs += ssplit(fname,".")[0];
    }
    return pkgs;
}
//DOC: `package get_installed_package(string name):`
//DOC: get package object from installed package name
public package get_installed_package(string name){
    package pkg = new package();
    string metadata = get_metadata_path(name);
    debug("Loading package metadata from: "+metadata);
    pkg.load(metadata);
    return pkg;
}

//DOC: `bool is_installed_package():`
//DOC: return true if package installed
public bool is_installed_package(string name){
    return isfile(get_metadata_path(name));
}

