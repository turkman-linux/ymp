//DOC: ## class package
//DOC: inary package struct & functions;
//DOC: Example usage:;
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
//DOC: ```;
public class package {
    private yamlfile yaml;
    public string name;
    public string version;
    public string[] dependencies;
    public string[] provides;
    private string pkgarea;
    private archive pkgfile;
    
    //DOC: `void package.load(string metadata):`;
    //DOC: Read package information from metadata file;
    public void load(string metadata){
        yaml = new yamlfile();
        yaml.load(metadata);
        pkgarea = yaml.get("inary.package");
        read_values();
    }

    //DOC: `void package.load_from_data(string data):`;
    //DOC: Read package information from string data;
    public void load_from_data(string data){
        yaml = new yamlfile();
        pkgarea = data;
        read_values();
    }

    //DOC: `void package.load_from_archive(string path):`;
    //DOC: Read package information from inary file;
    public void load_from_archive(string path){
        pkgfile = new archive();
        pkgfile.load(path);
        load_from_data(pkgfile.readfile("metadata.yaml"));
    }

    //DOC: `string[] package.list_files():`;
    //DOC: return inary package files list;
    public string[] list_files(){
        if(pkgfile == null){
            error_add("Package archive missing");
        }
        string files = pkgfile.readfile("files");
        return ssplit(files,"\n");
    }
    
    private void read_values(){
        name = get("name");
        version = get("version");
        dependencies = gets("dependencies");
        provides = gets("provides");
    }

    //DOC: `string[] package.gets(string name):`;
    //DOC: Get package array value;
    public string[] gets(string name){
        if (yaml.has_area(pkgarea,name)){
            return yaml.get_array(pkgarea,name);
        }
        return {};
    }
    
    //DOC: `string package.get(string name):`;
    //DOC: Get package value;
    public string get(string name){
        if (yaml.has_area(pkgarea,name)){
            debug(@"Package data: $name");
            return yaml.get_value(pkgarea,name);
        }
        warning(@"Package information broken: $name");
        return "";
    }
    public bool is_installed(){
        return is_installed_package(name);
    }
}

//DOC: ## Miscellaneous package functions
//DOC: package functions outside package class;

//DOC: `string[] list_installed_packages():`
//DOC: return installed package names array;
public string[] list_installed_packages(){
    string[] pkgs = {};
    foreach(string fname in listdir(get_storage()+"/metadata")){
        pkgs += ssplit(fname,".")[0];
    }
    return pkgs;
}

private string get_metadata_path(string name){
    return get_value("DESTDIR")+STORAGEDIR+"/metadata/"+name+".yaml";
}

//DOC: `package get_installed_packege(string name):`;
//DOC: get package object from installed package name;
public package get_installed_packege(string name){
    package pkg = new package();
    string metadata = get_metadata_path(name);
    debug(pwd());
    debug("Loading package metadata from: "+metadata);
    pkg.load(metadata);
    return pkg;
}

//DOC: `bool is_installed_package():`;
//DOC: return true if package installed;
public bool is_installed_package(string name){
    return isfile(get_metadata_path(name));
}

