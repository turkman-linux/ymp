public void build_target_ymp_init() {
    build_target ymp_target = new build_target();
    ymp_target.suffix = "ymp";
    ymp_target.name = "ymp";
    ymp_target.arch = getArch();
    ymp_target.create_source_archive.connect(() => {
        string buildpath = ymp_target.builder.ymp_build.ympbuild_buildpath;
        string curdir = pwd();
        cd(ymp_target.builder.ymp_build.ympbuild_srcpath);
        string metadata = ymp_target.builder.ymp_build.get_ympbuild_metadata();
        writefile(srealpath(buildpath + "/metadata.yaml"), metadata.strip() + "\n");
        var tar = new archive();
        tar.load(buildpath + "/source.zip");
        foreach(string file in ymp_target.builder.ymp_build.get_ympbuild_array("source")) {
            if (!endswith(file, ".ymp") && isfile(file)) {
                file = file[(ymp_target.builder.ymp_build.ympbuild_srcpath).length: ];
                create_dir(sdirname(buildpath + "/" + file));
                copy_file(ymp_target.builder.ymp_build.ympbuild_srcpath + file, buildpath + file);
            }
        }
        copy_file(ymp_target.builder.ymp_build.ympbuild_srcpath + "/ympbuild", buildpath + "/ympbuild");
        cd(buildpath);
        tar.add("metadata.yaml");
        foreach(string file in find(buildpath)) {
            file = file[(buildpath).length: ];
            if (file[0] == '/') {
                file = file[1: ];
            }
            if (file == "metadata.yaml") {
                continue;
            }
            if (file == null || file == "" || startswith(file, "output")) {
                continue;
            }
            tar.add(file);
        }
        set_archive_type("zip", "none");
        tar.create();
        cd(curdir);
        return buildpath + "/source.zip";
    });

    ymp_target.create_files_info.connect(() => {
        string curdir = pwd();
        string output = ymp_target.builder.ymp_build.ympbuild_buildpath + "/output/";
        cd(output);
        string files_data = "";
        string links_data = "";
        bool unsafe = get_bool("unsafe");
        foreach(string path in listdir(output)) {
            if (path == "metadata.yaml" || path == "icon.svg") {
                continue;
            }
            string fpath = output + path;
            if (issymlink(fpath)) {
                continue;
            } else if (!unsafe && isfile(fpath)) {
                error_add(_("Files are not allowed in root directory: /%s").printf(path));
            }
        }
        foreach(string file in find(output)) {
            if (" " in file) {
                continue;
            }
            if (isdir(file)) {
                continue;
            }
            if (!unsafe && filesize(file) == 0) {
                warning(_("Empty file detected: %s").printf(file));
            }
            if (issymlink(file)) {
                var link = sreadlink(file);
                if (!unsafe && link[0] == '/') {
                    string fixed_symlink = get_fixed_symlink(file[(output).length: ],link);
                    error_add(_("Absolute path symlink is not allowed:%s%s => %s (%s)").printf(
                        "\n    ", file[(output).length:], link, fixed_symlink)
                    );
                    continue;
                }
                if (!unsafe && !isexists(sdirname(file) + "/" + link) && link.length > 0) {
                    error_add(_("Broken symlink detected:%s%s => %s").printf("\n    ", file, link));
                    continue;
                }
                file = file[(output).length+1: ];
                debug(_("Link info add: %s").printf(file));
                links_data += file + " " + link + "\n";
                continue;
            } else {
                file = file[(output).length+1: ];
                if (file == "metadata.yaml" || file == "icon.svg") {
                    continue;
                }
                debug(_("File info add: %s").printf(file));
                files_data += calculate_sha1sum(file) + " " + file + "\n";
            }
        }
        if (has_error()) {
            cd(curdir);
            return false;
        }
        writefile(output + "/files", files_data);
        writefile(output + "/links", links_data);
        cd(curdir);
        return true;
    });

    ymp_target.create_metadata_info.connect(() => {
        string buildpath = ymp_target.builder.ymp_build.ympbuild_buildpath;
        string metadata = ymp_target.builder.ymp_build.get_ympbuild_metadata();
        bool unsafe = get_bool("unsafe");
        debug("Create metadata info: " + buildpath + "/output/metadata.yaml");
        var yaml = new yamlfile();
        yaml.data = metadata;
        string srcdata = yaml.get("ymp.source");
        string name = yaml.get_value(srcdata, "name");
        string release = yaml.get_value(srcdata, "release");
        string version = yaml.get_value(srcdata, "version");
        no_src = false;
        if (!yaml.has_area(srcdata, "archive")) {
            no_src = true;
            warning(_("Source array is not defined."));
        }
        string new_data = "ymp:\n";
        new_data += "  package:\n";
        string[] attrs = {
            "name",
            "version",
            "release",
            "description"
        };
        foreach(string attr in attrs) {
            new_data += "    " + attr + ": " + yaml.get_value(srcdata, attr) + "\n";
        }

        string[] arrys = {
            "provides",
            "replaces",
            "group"
        };
        foreach(string arr in arrys) {
            if (!yaml.has_area(srcdata, arr)) {
                continue;
            }
            string[] deps = yaml.get_array(srcdata, arr);
            if (deps.length > 0) {
                new_data += "    " + arr + ":\n";
                foreach(string dep in deps) {
                    new_data += "     - " + dep + "\n";
                }
            }
        }
        // calculate dependency list by use flag and base dependencies
        var deps = new array();
        if (yaml.has_area(srcdata, "depends")) {
            deps.adds(yaml.get_array(srcdata, "depends"));
        }
        if (unsafe) {
            new_data += "    unsafe: true/n";
        }
        string[] use_flags = ssplit(get_value("use"), " ");
        string package_use = get_config("package.use", name);
        if (package_use.length > 0) {
            use_flags = ssplit(package_use, " ");
        }
        if ("all" in use_flags) {
            use_flags = yaml.get_array(srcdata, "use-flags");
        }
        if (yaml.has_area(srcdata, "use-flags")) {
            foreach(string flag in use_flags) {
                info(_("Add use flag dependency: %s").printf(flag));
                string[] fdeps = yaml.get_array(srcdata, flag + "-depends");
                if (fdeps.length > 0) {
                    deps.adds(fdeps);
                }
            }
        }
        if (deps.length() > 0) {
            new_data += "    depends:\n";
            foreach(string dep in deps.get()) {
                new_data += "     - " + dep + "\n";
            }
        }
        if (release == "") {
            error_add(_("Release is not defined."));
        }
        if (version == "") {
            error_add(_("Version is not defined."));
        }
        if (name == "") {
            error_add(_("Name is not defined."));
        }
        bool arch_is_supported = false;
        foreach(string a in yaml.get_array(srcdata, "arch")) {
            if (a == getArch()) {
                arch_is_supported = true;
                break;
            }
        }
        if (!arch_is_supported) {
            error_add(_("Package architecture is not supported."));
        }
        if (has_error()) {
            return false;
        }
        ymp_target.builder.output_package_name = name + "_" + version + "_" + release;
        create_dir(buildpath + "/output/");
        writefile(buildpath + "/output/metadata.yaml", trim(new_data));
        return true;
    });

    ymp_target.create_data_file.connect(() => {
        string buildpath = ymp_target.builder.ymp_build.ympbuild_buildpath;
        debug(_("Create data file: %s/output/data.tar.gz").printf(buildpath));
        var tar = new archive();
        if (get_value("compress") == "none") {
            tar.load(buildpath + "/output/data.tar");
            set_archive_type("tar", "none");
        } else if (get_value("compress") == "gzip") {
            tar.load(buildpath + "/output/data.tar.gz");
            set_archive_type("tar", "gzip");
        } else if (get_value("compress") == "xz") {
            tar.load(buildpath + "/output/data.tar.xz");
            set_archive_type("tar", "xz");
        } else {
            // Default format (gzip)
            tar.load(buildpath + "/output/data.tar.gz");
            set_archive_type("tar", "gzip");
        }
        int fnum = 0;
        string curdir = pwd();
        cd(buildpath + "/output/");
        foreach(string file in find("./")) {
            if (isdir(file)) {
                continue;
            }
            file = file[3: ];
            info(_("Compress: %s").printf(file));
            if (file == "files" || file == "links" || file == "metadata.yaml" || file == "icon.svg") {
                continue;
            }
            tar.add(file);
            fnum++;
        }
        if (isfile(buildpath + "/output/data.tar.gz")) {
            remove_file(buildpath + "/output/data.tar.gz");
        }
        if (fnum != 0) {
            tar.create();
        }
        cd(curdir);
        string hash = calculate_sha1sum(buildpath + "/output/data.tar.gz");
        int size = filesize(buildpath + "/output/data.tar.gz");
        string new_data = readfile(buildpath + "/output/metadata.yaml");
        new_data += "    archive-hash: " + hash + "\n";
        new_data += "    arch: " + getArch() + "\n";
        new_data += "    archive-size: " + size.to_string() + "\n";
        writefile(buildpath + "/output/metadata.yaml", trim(new_data));

    });

    ymp_target.create_binary_package.connect(() => {
        string buildpath = ymp_target.builder.ymp_build.ympbuild_buildpath;

        string curdir = pwd();
        cd(buildpath + "/output/");
        ymp_target.create_data_file();
        var tar = new archive();
        tar.load(buildpath + "/package.zip");
        tar.add("metadata.yaml");
        tar.add("files");
        tar.add("links");
        if (isfile("icon.svg")) {
            tar.add("icon.svg");
        }
        foreach(string path in listdir(".")) {
            if (isfile(path) && startswith(path, "data")) {
                tar.add(path);
            }
        }
        set_archive_type("zip", "none");
        tar.create();
        cd(curdir);
        return buildpath + "/package.zip";
    });
    add_build_target(ymp_target);
}
