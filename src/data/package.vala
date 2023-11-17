//DOC: ## class package
//DOC: ymp package struct & functions
//DOC: Example usage:
//DOC: ```vala
//DOC: var pkg = new package ();
//DOC: pkg.load_from_archive ("/tmp/bash-5.0-x86_64.ymp");
//DOC: stdout.printf (pkg.get ("archive-hash"));
//DOC: foreach (string pkgname in pkg.dependencies) {
//DOC:     stdout.printf (pkgname);
//DOC: }
//DOC: var pkg2 = new package ();
//DOC: pkg2.load ("/tmp/metadata.yaml");
//DOC: if (pkg2.is_installed ()) {
//DOC:     stdout.printf (pkg2 + " installed");
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
    public string target;
    private archive pkgfile;

    //DOC: `void package.load (string path):`
    //DOC: Read package information from metadata file
    public void load (string path) {
        string ctx = readfile_raw (path);
        load_from_data (trim (ctx));
    }

    //DOC: `void package.load_from_data (string data):`
    //DOC: Read package information from string data
    public void load_from_data (string metadata) {
        yaml = new yamlfile ();
        string ympdata = "";
        debug( _("Metadata detection"));
        if (yaml.has_area (metadata, "ymp")) {
            ympdata = yaml.get_area (metadata, "ymp");
        }else if (yaml.has_area (metadata, "package") || yaml.has_area (metadata, "source")) {
            ympdata = metadata;
        }else {
            error_add (_ ("Package metadata file is broken: %s").printf (metadata));
        }
        debug( _("Load pkgarea"));
        if (yaml.has_area (ympdata, "package")) {
            is_source = false;
            pkgarea = yaml.get_area (ympdata, "package");
        }else if (yaml.has_area (ympdata, "source")) {
            is_source = true;
            pkgarea = yaml.get_area (ympdata, "source");
        }else {
            error_add (_ ("Package data is broken: %s").printf (ympdata));
        }
        error (2);
        debug( _("Read package values"));
        read_values ();
    }

    public void set_pkgarea (string area, bool is_src) {
        yaml = new yamlfile ();
        pkgarea = area;
        is_source = is_src;
        //read values from data
        read_values ();
    }

    //DOC: `void package.load_from_archive (string path):`
    //DOC: Read package information from ymp file
    public void load_from_archive (string path) {
        pkgfile = new archive ();
        pkgfile.load (srealpath (path));
        var metadata = pkgfile.readfile ("metadata.yaml");
        info (_ ("Load package from: %s").printf (path));
        load_from_data (metadata);
    }

    //DOC: `string[] package.list_files ():`
    //DOC: return ymp package files list
    public string[] list_files () {
        if (pkgfile == null) {
            if (is_installed_package (name)) {
                string files = readfile_raw (get_storage () + "/files/" + name);
                return ssplit (files, "\n");
            }
            error_add (_ ("Package archive is missing."));
            error (2);
            return {};
        }
        string files = pkgfile.readfile ("files");
        return ssplit (files, "\n");
    }

    //DOC: `string[] package.list_files ():`
    //DOC: return ymp package files list
    public string[] list_links () {
        if (pkgfile == null) {
            if (is_installed_package (name)) {
                string links = readfile_raw (get_storage () + "/links/" + name);
                return ssplit (links, "\n");
            }
            error_add (_ ("Package archive is missing."));
            return {};
        }
        string links = pkgfile.readfile ("links");
        return ssplit (links, "\n");
    }

    private void read_values () {
        name = get ("name");
        version = get ("version");
        var a = new array ();
        a.adds (gets ("depends"));
        if (is_source) {
            a.adds (gets ("makedepends"));
            string[] use_flags = ssplit (get_value ("use"), " ");
            string[] package_use = ssplit (get_config ("package.use", name), " ");
            if (package_use.length > 0) {
                use_flags = package_use;
            }
            if ("all" in use_flags) {
                foreach (string flag in gets ("use-flags")) {
                   a.adds (gets (flag + "-depends"));
                }
            }else {
                foreach (string flag in use_flags) {
                   a.adds (gets (flag + "-depends"));
                }
            }
        }
        dependencies = a.get ();
        release = int.parse (get ("release"));
    }

    //DOC: `string[] package.gets (string name):`
    //DOC: Get package array value
    public string[] gets (string name) {
        if (yaml.has_area (pkgarea, name)) {
            debug (_ ("Package data: %s").printf (name));
            return yaml.get_array (pkgarea, name);
        }
        return {};
    }

    //DOC: `string package.get (string name):`
    //DOC: Get package value
    public string get (string fname) {
        debug (_ ("Get package data %s:%s").printf (name, fname));
        if (yaml.has_area (pkgarea, fname)) {
            debug (_ ("Package data: %s").printf (name));
            return yaml.get_value (pkgarea, fname);
        }
        warning (_ ("Package information is broken: %s %s").printf (fname, name));
        return "";
    }
    //DOC: `string package.is_unsafe ():`
    //DOC: Check package is unsafe
    public bool is_unsafe () {
        debug (_ ("Check package unsafe %s").printf (name));
        if (yaml.has_area (pkgarea, "unsafe")) {
            return true;
        }
        return false;
    }

    //DOC: `string package.get_uri ():`
    //DOC: get repository uri
    public string get_uri () {
        if (repo_address == null) {
            return "";
        }
        string uri = get ("uri");
        debug (_ ("Get package uri: %s").printf (uri));
        return repo_address.replace ("$uri", uri);
    }


    //DOC: `void package.download ():`
    //DOC: download package file from repository
    public void download () {
        target = get_storage () + "/packages/" + sbasename (get_uri ());
        download_only ();
        pkgfile = new archive ();
        pkgfile.load (target);
    }

    public void download_only () {
        target = get_storage () + "/packages/" + sbasename (get_uri ());
        if (isfile (target)) {
            info (_ ("File already exists: %s").printf (target));
        }else if (get_uri () != "") {
            if (!fetch (get_uri (), target)) {
                error_add (_ ("Failed to fetch package: %s").printf (get_uri ()));
            }
        }else {
            error_add (_ ("Package is not downloadable: %s").printf (name));
        }
        string target_sum = calculate_md5sum (target);
        if (get ("md5sum") != target_sum) {
            error_add (_ ("Package md5sum mismatch: %s").printf (target));
            remove_file (target);
        }
    }

    //DOC: `void package.extract ():`
    //DOC: extract package to quarantine directory
    //DOC: quarantine directory is **get_storage () + "/quarantine"**;
    //DOC: Example ymp archive format:
    //DOC: ```yaml
    //DOC: package.ymp
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
    public void extract () {
        create_dir (get_storage () + "/quarantine/metadata");
        create_dir (get_storage () + "/quarantine/rootfs");
        create_dir (get_storage () + "/quarantine/files");
        create_dir (get_storage () + "/quarantine/links");
        if (pkgfile == null) {
            error_add (_ ("Package archive is missing."));
            return;
        }
        var rootfs_medatata = get_storage () + "/quarantine/metadata/";
        var rootfs_files = get_storage () + "/quarantine/files/";
        var rootfs_links = get_storage () + "/quarantine/links/";
        if (isfile (rootfs_medatata + name + ".yaml")) {
            debug (_ ("Skip quartine package extract: %s").printf (name));
            return;
        }
        // extract data archive
        pkgfile.set_target (get_storage () + "/quarantine");
        foreach (string data in pkgfile.list_files ()) {
            // Allowed formats: data.tar.xz data.zip data.tar.zst data.tar.gz ..
            if (startswith (data, "data.")) {
                // 1. data.* file extract to quarantine from ymp package
                pkgfile.extract (data);
                var datafile = get_storage () + "/quarantine/" + data;
                // 2. validate data archive
                var data_hash = calculate_sha1sum (datafile);
                if (data_hash != get ("archive-hash")) {
                    error_add (_ ("Archive sha1sum mismatch."));
                    remove_file (datafile);
                }
                // 3. data.* package extract to quarantine/rootfs
                var file_archive = new archive ();
                file_archive.load (datafile);
                file_archive.set_target (get_storage () + "/quarantine/rootfs");
                file_archive.extract_all ();
                // 4. remove data.* file
                remove_file (datafile);
                break;
            }
        }
        // extract metadata
        if (isfile (rootfs_medatata + "metadata.yaml")) {
            remove_file (rootfs_medatata + "metadata.yaml");
        }
        pkgfile.set_target (rootfs_medatata);
        pkgfile.extract ("metadata.yaml");
        move_file (rootfs_medatata + "metadata.yaml", rootfs_medatata + name + ".yaml");
        // extract files
        pkgfile.set_target (rootfs_files);
        pkgfile.extract ("files");
        move_file (rootfs_files + "files", rootfs_files + name);
        // extract links
        pkgfile.set_target (rootfs_links);
        pkgfile.extract ("links");
        move_file (rootfs_links + "links", rootfs_links + name);
        error (3);
    }
    //DOC: `void package.build ():`
    //DOC: build source code into buildpath
    public void build () {
        if (pkgfile == null) {
            error_add (_ ("Package archive is missing."));
            return;
        }
        string curdir = pwd ();
        var build = new builder ();
        create_dir (get_build_dir () + "/" + name);
        pkgfile.set_target (get_build_dir () + "/" + name);
        build.ymp_build.set_ympbuild_srcpath (get_build_dir () + "/" + name);
        build.ymp_build.set_ympbuild_buildpath (get_build_dir () + "/" + name);
        if (!get_bool ("no-clear")) {
            remove_all (build.ymp_build.ympbuild_buildpath);
        }
        pkgfile.set_target (get_build_dir () + "/" + name);
        pkgfile.extract_all ();
        build.set_build_target (get_build_dir () + "/" + name);
        build.ymp_build.set_ympbuild_buildpath (get_build_dir () + "/" + name);
        build.build_target.create_metadata_info ();
        build.fetch_package_sources ();
        build.extract_package_sources ();
        build.build_package ();
        error (1);
        quarantine_import_from_path (build.ymp_build.ympbuild_buildpath + "/output");
        cd (curdir);
    }


    //DOC: `bool package.is_installed ():`
    //DOC: return true if package is installed
    public bool is_installed () {
        return is_installed_package (name);
    }
}

//DOC: ## Miscellaneous package functions
//DOC: package functions outside package class

//DOC: `string[] list_installed_packages ():`
//DOC: return installed package names array
public string[] list_installed_packages () {
    string[] pkgs = {};
    foreach (string fname in listdir (get_storage () + "/metadata")) {
        pkgs += fname[:-5];
    }
    csort (pkgs, pkgs.length);
    return pkgs;
}
//DOC: `package get_installed_package (string name):`
//DOC: get package object from installed package name
public package get_installed_package (string name) {
    package pkg = new package ();
    string metadata = get_metadata_path (name);
    debug (_ ("Loading package metadata from: %s").printf (metadata));
    pkg.load (metadata);
    return pkg;
}

//DOC: `bool is_installed_package ():`
//DOC: return true if package installed
public bool is_installed_package (string name) {
    if ("|" in name) {
        foreach (string f in ssplit (name, "|")) {
            if (isfile (get_metadata_path (f))) {
                return true;
            }
        }
        return false;
    }
    return isfile (get_metadata_path (name));
}
