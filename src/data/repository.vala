//DOC: ## class repository
//DOC: repository object to list or select packages from repository
//DOC: Example usage:
//DOC: ```vala
//DOC: var repo = new repository ();
//DOC: repo.load ("main.yaml");
//DOC: if (repo.has_package ("bash")) {
//DOC:     stdout.printf ("Package found.");
//DOC: }
//DOC: foreach (string name in repo.list_packages ()) {
//DOC:     package pkg = repo.get_package (name);
//DOC:     stdout.printf (pkg.version);
//DOC: }
//DOC: ```
public class repository {
    private yamlfile yaml;
    public string name;
    public string address;
    private string indexarea;
    private string[] packages;
    private string[] sources;
    private string[] package_names;
    private string[] source_names;

    //DOC: `void repository.load (string repo_name):`
    //DOC: load repository data from repo name
    public void load (string repo_name) {
        yaml = new yamlfile ();
        yaml.load (get_storage () + "/index/" + repo_name);
        indexarea = yaml.get ("index");
        name = yaml.get_value (indexarea, "name");
        address = yaml.get_value (indexarea, "address");
        packages = yaml.get_area_list (indexarea, "package");
        sources = yaml.get_area_list (indexarea, "source");
        var a = new array ();
        foreach (string area in packages) {
            a.add (yaml.get_value (area, "name"));
        }
        package_names = a.get ();
        a = new array ();
        foreach (string area in sources) {
            a.add (yaml.get_value (area, "name"));
        }
        source_names = a.get ();
    }

    //DOC: `bool repository.has_package (string name):`
    //DOC: return true if package exists in repository
    public bool has_package (string name) {
        return name in package_names;
    }

    //DOC: `bool repository.has_package (string name):`
    //DOC: return true if package exists in repository
    public bool has_source (string name) {
        return name in source_names;
    }

    //DOC: `package repository.get_source (string name):`
    //DOC: get package object from repository by source name
    public package get_source (string name) {
        package pkg = null;
        int currel = 0;
        foreach (string fname in source_names) {
            if (fname == name) {
                foreach (int index in sindex (fname, source_names)) {
                            string area = sources[index];
                            int release = int.parse (yaml.get_value (area, "release"));
                            if (release <= currel) {
                                continue;
                            }
                            currel = release;
                            pkg = new package ();
                            pkg.set_pkgarea (area, true);
                            pkg.repo_address = address;
                }
            }
        }
        return pkg;
    }

    //DOC: `package repository.get_package (string name):`
    //DOC: get package object from repository by package name
    public package get_package (string name) {
        package pkg = null;
        int currel = 0;
        foreach (string fname in package_names) {
            if (fname == name) {
                foreach (int index in sindex (fname, package_names)) {
                            string area = packages[index];
                            int release = int.parse (yaml.get_value (area, "release"));
                            if (release <= currel) {
                                continue;
                            }
                            currel = release;
                            pkg = new package ();
                            pkg.set_pkgarea (area, false);
                            pkg.repo_address = address;
                }
            }
        }
        return pkg;
    }

    //DOC: `string[] repository.list_packages ():`
    //DOC: get all available package names from repository
    public string[] list_packages () {
        return package_names;
    }

    //DOC: `string[] repository.list_sources ():`
    //DOC: get all available source names from repository
    public string[] list_sources () {
        return source_names;
    }

}

//DOC: ## Miscellaneous repository functions
//DOC: repository functions outside repository class

private repository[] repos;

//DOC: `repository[] get_repos ():`
//DOC: get all repositories as array
public repository[] get_repos () {
    string force_repo = get_value ("repo");
    if (repos == null) {
        repos = {};
    }else {
        return repos;
    }
    foreach (string file in listdir (get_storage () + "/index")) {
        repository repo = new repository ();
        repo.load (file);
        if(repo.name == ""){
            continue;
        }
        if (force_repo == "" || force_repo == repo.name) {
            repos += repo;
        }
    }
    return repos;
}

//DOC: `bool is_available_package (string name):`
//DOC: return true if package is available
public bool is_available_package (string name) {
    foreach (repository repo in get_repos ()) {
        if (repo.has_package (name)) {
            return true;
        }
    }
    return false;
}


//DOC: `bool is_available_source (string name):`
//DOC: return true if package is available
public bool is_available_source (string name) {
    foreach (repository repo in get_repos ()) {
        if (repo.has_source (name)) {
            return true;
        }
    }
    return false;
}

//DOC: `package is_available_from_repository (string name):`
//DOC: return true if package/source is available
public bool is_available_from_repository (string name) {
    if (get_bool ("no-emerge")) {
        return is_available_package (name);
    }else {
        return is_available_source (name);
    }
}

//DOC: `package get_package_from_repository (string name):`
//DOC: get package object from all repositories
public package get_package_from_repository (string name) {
    int release = 0;
    package ret = null;

    foreach (repository repo in get_repos ()) {
        package pkg = repo.get_package (name);
        if (pkg != null) {
            if (int.parse (pkg.get ("release")) > release) {
                pkg.repo_address = repo.address;
                release = int.parse (pkg.get ("release"));
                ret = pkg;
            }
        }
    }
    if (ret == null) {
        if (get_bool ("ignore-satisfied")) {
            return ret;
        }
        error_add (_ ("Package is not satisfied from repository: %s").printf (name));
    }
    return ret;
}

//DOC: `package get_package (string name):`
//DOC: get package from automatically detected source
public package get_package (string name) {
    if (isfile(name)){
         return get_package_from_file(name);
    }else if (is_available_from_repository(name)) {
        return get_from_repository(name);
    } else if (is_installed_package(name)) {
        return get_installed_package(name);
    }else {
        return new package();
    }
}


//DOC: `package get_source_from_repository (string name):`
//DOC: get source package object from all repositories
public package get_source_from_repository (string name) {
    int release = 0;
    package ret = null;
    foreach (repository repo in get_repos ()) {
        package pkg = repo.get_source (name);
        if (pkg != null) {
            if (int.parse (pkg.get ("release")) > release) {
                pkg.repo_address = repo.address.replace ("ymp-index.yaml", "$uri");
                release = int.parse (pkg.get ("release"));
                ret = pkg;
            }
        }
    }
    if (ret == null) {
        if (get_bool ("ignore-satisfied")) {
            return ret;
        }
        error_add (_ ("Package is not satisfied from repository: %s").printf (name));
    }
    return ret;
}

//DOC: `package get_from_repository (string name):`
//DOC: return package if no-emerge else return source
public package get_from_repository (string name) {
    if (startswith (name, "src:")) {
        return get_source_from_repository (name[4:]);
    }else if (startswith (name, "pkg:")) {
        return get_package_from_repository (name[4:]);
    }
    if (get_bool ("no-emerge")) {
        return get_package_from_repository (name);
    }else {
        return get_source_from_repository (name);
    }
}


//DOC: `package get_package_from_file (string path):`
//DOC: get package object from ymp file archive
public package get_package_from_file (string path) {
    package pkg = new package ();
    pkg.load_from_archive (srealpath (path));
    return pkg;
}

//DOC: `string[] get_repo_address ():`
//DOC: return repository adress list
public string[] get_repo_address () {
    string repolist = "";
    info (_ ("Find repo list: %s").printf (get_storage () + "/sources.list"));
    if (isdir (get_storage () + "/sources.list.d")) {
        foreach (string file in find (get_storage () + "/sources.list.d")) {
            if (isfile (file)) {
                info (_ ("Find repo list: %s").printf (file));
                repolist += readfile (file) + "\n";
            }
        }
    }
    repolist += readfile (get_storage () + "/sources.list") + "\n";
    return ssplit (repolist, "\n");
}

//DOC: `void update_repo ():`
//DOC: update local repository index
public void update_repo () {
    remove_all (get_storage () + "/index");
    create_dir (get_storage () + "/index");
    foreach (string repo in get_repo_address ()) {
        if (repo == "" || repo == null) {
            continue;
        }
        string repox = repo;
        repo = repo.replace ("$uri", "ymp-index.yaml");
        string name = repo.replace ("/", "-");
        string path = get_storage () + "/index/" + name;
        fetch (repo, path);
        string index_data = readfile_raw (path);
        if (!startswith (index_data, "index:")) {
            error_add (_ ("Invalid repository index: %s").printf (name));
            remove_file (path);
            continue;
        }
        index_data += "\n  address: " + repox;
        writefile (path, index_data);
        if (!get_bool ("ignore-gpg")) {
            fetch (repo + ".gpg", path + ".gpg");
            if (!verify_file (path)) {
                error_add ("Gpg check failed.");
             }
        }
    }
    error (2);
}

public string[] list_available_packages () {
    array ret = new array();
    foreach (repository repo in get_repos ()) {
        if (get_bool ("no-emerge")) {
            ret.adds(repo.list_packages ());
        }else {
            ret.adds(repo.list_sources ());
       }
    }
    return ret.get();
}


private string[] index_a;
private void create_index_single(repo_index_ctx *ctx) {
    array a = new array();
    var tar = new archive ();
    var yaml = new yamlfile ();
    string file = ctx->file;
    string path = ctx->path;
    // name lists
    string[] srcs = {};
    string[] pkgs = {};
    // tmp variable
    string nam = "";
    string dat = "";
    string rel = "";
    string md5sum = calculate_md5sum (file);
    string sha256sum = calculate_sha256sum (file);
    uint64 size = filesize (file);
    tar.load (file);
    file = file[path.length:];
    info ("Index: " + file);
    string  metadata = tar.readfile ("metadata.yaml");
    string ymparea = yaml.get_area (metadata, "ymp");
    if (!get_bool ("ignore-check")) {
        if (yaml.has_area (ymparea, "source")) {
            dat = yaml.get_area (ymparea, "source");
            nam = yaml.get_value (dat, "name");
            rel = yaml.get_value (dat, "release");
            if (nam + "-" + rel in srcs) {
                warning (_ ("A source has multiple versions: %s").printf (nam));
            }
            srcs += nam + "-" + rel;
        }
        if (yaml.has_area (ymparea, "package")) {
            dat = yaml.get_area (ymparea, "package");
            nam = yaml.get_value (dat, "name");
            rel = yaml.get_value (dat, "release");
            if (nam + "-" + rel in pkgs) {
                warning (_ ("A package has multiple versions: %s").printf (nam));
            }
            pkgs += nam + "-" + rel;
        }
    }
    foreach (string line in ssplit (ymparea, "\n")) {
        if (line == "" || line == null) {
            continue;
        }
        a.add("  %s\n".printf(line));
    }
    a.add("    md5sum: %s\n".printf(md5sum));
    a.add("    sha256sum: %s\n".printf(sha256sum));
    a.add("    size: %s\n".printf(size.to_string ()));
    a.add("    uri: %s\n\n".printf(file));
    index_a[ctx->number] = a.get_string();
}

private class repo_index_ctx {
    public string path;
    public string file;
    public int number;
}

//DOC: `string create_index_data (string fpath):`
//DOC: generate remote repository index data
public string create_index_data (string fpath) {
    var a = new array();
    a.add("index:\n");
    
    string path = srealpath (fpath);
    string index_name = get_value ("name");
    if (index_name == "") {
        error_add (_ ("Index name is not defined. Please use --name=xxx"));
        error (1);
    }
    a.add("  name: %s\n".printf(index_name));
    foreach (string file in find (path)) {
        if (endswith (file, ".ymp")) {
            if (get_bool ("move")) {
                string fname = sbasename (file);
                string dir=fname[:1];
                if (startswith (fname, "lib")) {
                    dir=fname[:4];
                }
                dir = dir + "/" + ssplit (fname, "_")[0] + "/";
                string target = srealpath (path + "/" + dir + fname);
                if (srealpath (file) != target) {
                    create_dir (path + "/" + dir);
                    move_file (file, target);
                    file = target;
                }
            }
        }
    }

    jobs j = new jobs();
    int i=0;
    foreach (string file in find (path)) {
        if (!endswith (file, ".ymp")) { // skip for non ymp files
            continue;
        }
        // create context for index
        repo_index_ctx *ctx = new repo_index_ctx();
        ctx->path = path; // index path
        ctx->file= file; // file path
        ctx->number=i; // file index
        j.add((void*)create_index_single, ctx, ctx); // run async 
        i++; // increase index
    }
    index_a = new string[i]; // allocate string array
    j.run(); // run all jobs
    for(int ii = 0;ii < i;ii++){
       a.add(index_a[ii]);  // copy all data into array library
    }
    return a.get_string();
}
