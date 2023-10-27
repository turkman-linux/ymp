//DOC: `int deb_extract (string file, string output):`
//DOC: extract debian packages
public int deb_extract (string debfile, string output) {
    create_dir (output);
    var deb = new archive ();
    deb.load (debfile);
    deb.set_target (output);
    foreach (string file in deb.list_files ()) {
        if (startswith (file, "data.tar.")) {
            deb.extract (file);
            var data = new archive ();
            data.load (output + "/" + file);
            data.set_target (output);
            data.extract_all ();
            remove_file (output + "/" + file);
        }else if (startswith (file, "control.tar.")) {
            deb.extract (file);
            var control = new archive ();
            control.load (output + "/" + file);
            control.set_target (output + "/DEBIAN");
            control.extract_all ();
            remove_file (output + "/" + file);
            remove_file (output + "/DEBIAN/md5sums");
        }
    }
    return 0;
}

public int deb_create (string fpath, string output) {
    // create data.tar.gz
    var data = new archive ();
    string path = srealpath (fpath);
    data.load (output + "/data.tar.gz");
    string curdir = pwd ();
    cd (path);
    string md5sum_data = "";
    foreach (string dir in listdir ("./")) {
        if (startswith (dir, "DEBIAN")) {
            continue;
        }
        foreach (string file in find (dir)) {
            if (isfile (file) && ! issymlink (file)) {
                string md5 = calculate_md5sum (path + "/" + file);
                md5sum_data += "%s  %s\n".printf (md5, file);
            }
            data.add (file);
        }
    }
    set_archive_type ("tar", "gzip");
    data.create ();
    cd (curdir);
    // update md5sums
    writefile (path + "/DEBIAN/md5sums", md5sum_data);
    // create control.tar.gz
    cd (path + "/DEBIAN");
    var control = new archive ();
    control.load (output + "/control.tar.gz");
    foreach (string file in listdir (".")) {
        control.add (file);
    }
    set_archive_type ("tar", "gzip");
    control.create ();
    writefile (output + "/debian-binary", "2.0\n");
    cd (output);
    string target="%s/%s.deb".printf (output, sbasename (path));
    print (colorize (_ ("Creating debian package to: %s"), yellow).printf (target));
    var debfile = new archive ();
    debfile.load (target);
    debfile.add ("debian-binary");
    debfile.add ("control.tar.gz");
    debfile.add ("data.tar.gz");
    set_archive_type ("ar", "none");
    debfile.create ();
    remove_file ("debian-binary");
    remove_file ("control.tar.gz");
    remove_file ("data.tar.gz");
    cd (curdir);
    return 0;
}

public int debian_convert (string file) {
    string output = BUILDDIR + sbasename (file);
    if (isdir (output)) {
        remove_all (output);
    }
    var fbuilder = new builder ();
    fbuilder.ymp_build.set_ympbuild_buildpath (output);
    deb_extract (file, output + "/output");
    create_debian_metadata (output + "/output");
    fbuilder.build_target.create_files_info ();
    string binpkg = fbuilder.build_target.create_binary_package ();
    string target = file[:-4]+"."+fbuilder.build_target.suffix;
    if (get_bool ("install")) {
        set_bool ("no-emerge", true);
        install_main ({binpkg});
    } else {
        move_file (binpkg, target);
    }
    return 0;
}

public int debian_update_catalog () {
    string mirror = "https://ftp.debian.org/debian/";
    if (get_value ("mirror") != "") {
        mirror = get_value ("mirror");
    }
    fetch (mirror + "/dists/unstable/main/source/Sources.gz", "/tmp/.debian-catalog.gz");
    if (isfile ("/tmp/.debian-catalog")) {
        remove_file ("/tmp/.debian-catalog");
    }
    if (0 != run ("gzip -d /tmp/.debian-catalog.gz")) {
        error_add (_ ("Failed to decompress debian repository index."));
    }
    string data = readfile_raw ("/tmp/.debian-catalog");
    string src="";
    string fdata = "";
    foreach (string line in ssplit (data, "\n")) {
       if (startswith (line, "Package:")) {
           src=line[8:];
       }else if (startswith (line, "Binary:")) {
           fdata += "%s : %s \n".printf (
               src.strip (),
               line[7:].replace (", ", " ").replace ("/", "").strip ()
           );
       }
    }
    create_dir (get_storage () + "/debian/");
    writefile (get_storage () + "/debian/catalog", fdata);
    remove_file ("/tmp/.debian-catalog");
    return 0;
}

private string[] catalog_cache = null;
public string find_debian_pkgname_from_catalog (string fname) {
    string name = fname;
    if ("|" in name) {
        name=ssplit (name, "|")[0];
    }
    if (" (" in name) {
        name=ssplit (name, " (")[0];
    }
    name = name.strip ();
    if (catalog_cache == null) {
        if (!isfile (get_storage () + "/debian/catalog")) {
            error_add (_ ("Debian catalog does not found. Please use --update-catalog to update."));
        }
        error (2);
        catalog_cache = ssplit (readfile_raw (get_storage () + "/debian/catalog"), "\n");
    }
    foreach (string line in catalog_cache) {
        if (" %s ".printf (name) in line + " ") {
            return ssplit (line, ":")[0].strip ();
        }
    }
    return "";
}

public void create_debian_metadata (string path) {
    string control = readfile_raw (path + "/DEBIAN/control");
    string data = "ymp:\n";
    data +="  package:\n";
    string name="";
    foreach (string line in control.split ("\n")) {
        if (":" in line) {
           string var = line.split (":")[0].strip ();
           string val = line[var.length + 1:].strip ();
           if (var == "Package") {
               name=val;
               data +="    name: %s\n".printf (val);
           }else if (var == "Version") {
               data +="    version: %s\n".printf (val);
               data +="    release: 1\n";
           }else if (var == "Description") {
               data +="    description: %s\n".printf (val);
           }else if (var == "Depends") {
               data +="    depends:\n";
               string[] deps = {};
               foreach (string deb in ssplit (val, ", ")) {
                   string fdep = find_debian_pkgname_from_catalog (deb);
                   if (fdep.strip () != "" && fdep != name) {
                       deps += fdep;
                   }
               }
               deps = debian_packagename_fix (deps);
               foreach (string dep in deps){
                   data +="      - %s\n".printf (dep);
               }
           }
        }
    }
    data +="    arch: %s\n".printf (getArch ());
    data +="    unsafe: true\n";
    data +="    group:\n";
    data +="      - debian\n";
    data +="      - unsafe\n";
    writefile (path + "/metadata.yaml", data);
    remove_all (path + "/DEBIAN/");
}

private string[] debian_packagename_fix (string[] names){
    var yaml = new yamlfile();
    if(!isfile ("/etc/debian-names.yaml")) {
        return names;
    }
    yaml.load("/etc/debian-names.yaml");
    string area = yaml.get("debian");
    var ret = new array();
    foreach (string name in names) {
        name = name.strip();
        string fname = yaml.get_value(area, name).strip();
        if (fname == "" || fname == null) {
            fname = name;
        }
        if (fname == "" || fname == null) {
            continue;
        }
        if (startswith(fname, "python3-")) {
            fname = fname.replace ("python3-","py3-");
        }
        ret.add (fname);
    }
    ret.uniq();
    ret.sort();
    return ret.get ();
}
