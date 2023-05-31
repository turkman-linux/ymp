public int search_main (string[] args) {
    if (get_bool ("package")) {
        return search_pkgrepo_main (args);
    }else if (get_bool ("source")) {
        return search_srcrepo_main (args);
    }else if (get_bool ("file")) {
        return search_files_main (args);
    }else if (get_bool ("installed")) {
        return search_installed_main (args);
    }else {
        error_add (_ ("No options given. Please use --source or --package or --file or --installed ."));
        return 1;
    }
}

public int search_installed_main (string[] args) {
    foreach (string pkg in list_installed_packages ()) {
        var p = get_installed_package (pkg);
        foreach (string arg in args) {
            if (arg in p.get ("description") || arg in p.name) {
                print ( (p.name + "\t" + p.get ("description")).replace (arg, colorize (arg, red)));
            }
        }
    }
    return 0;
}


public int search_pkgrepo_main (string[] args) {
    foreach (repository repo in get_repos ()) {
        foreach (string pkg in repo.list_packages ()) {
            var p = repo.get_package (pkg);
            foreach (string arg in args) {
                if (arg in p.get ("description") || arg in p.name ) {
                    int color = red;
                    if (is_installed_package (p.name)) {
                        color = green;
                    }
                    print ("%s\t%s".printf (p.name, p.get ("description")).replace (arg, colorize (arg, color)));
                }
            }
        }
    }
    return 0;
}

public int search_srcrepo_main (string[] args) {
    foreach (repository repo in get_repos ()) {
        foreach (string pkg in repo.list_sources ()) {
            var p = repo.get_source (pkg);
            foreach (string arg in args) {
                if (arg in p.get ("description") || arg in p.name ) {
                    int color = red;
                    if (is_installed_package (p.name)) {
                        color = green;
                    }
                    print ("%s\t%s".printf (p.name, p.get ("description")).replace (arg, colorize (arg, color)));
                }
            }
        }
    }
    return 0;
}

public int search_files_main (string[] args) {
    foreach (string pkg in list_installed_packages ()) {
        string files = readfile ("%s/files/%s".printf (get_storage (), pkg));
        foreach (string file in files.split ("\n")) {
            if (file.length < 41) {
                continue;
            }
            foreach (string arg in args) {
                if (Regex.match_simple (arg, "/" + file[41:])) {
                    print ("%s => /%s".printf (pkg, file[41:]));
                }
            }
        }
    }
    return 0;
}

public string[] search_file (string[] args) {
    var pkgs = new array ();
    foreach (string pkg in list_installed_packages ()) {
        string files = readfile ("%s/files/%s".printf (get_storage (), pkg));
        foreach (string file in files.split ("\n")) {
            if (file.length < 41) {
                continue;
            }
            foreach (string arg in args) {
                if (Regex.match_simple (arg, "/" + file[41:])) {
                    pkgs.add (pkg);
                }
            }
        }
    }
    return pkgs.get ();

}

void search_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (search_main);
    op.names = {_ ("search"), "search", "sr"};
    op.help.name = _ ("search");
    op.help.minargs=1;
    op.help.description = _ ("Search packages.");
    op.help.add_parameter ("--package", _ ("search package in binary package repository"));
    op.help.add_parameter ("--source", _ ("search package in source package repository"));
    op.help.add_parameter ("--installed", _ ("search package in installed packages"));
    op.help.add_parameter ("--file", _ ("searches for packages by package file"));
    add_operation (op);
}
