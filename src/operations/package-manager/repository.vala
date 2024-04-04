private static int index_main (string[] args) {
    backup_env();
    clear_env();
    set_env("PATH","/sbin:/bin:/usr/sbin:/usr/bin");
    foreach (string arg in args) {
        string path = srealpath (arg);
        string index = create_index_data (path);
        writefile (path + "/ymp-index.yaml", index);
        sign_file (path + "/ymp-index.yaml");
        gpg_export_file (path + "/ymp-index.yaml.asc");
    }
    restore_env();
    return 0;
}

private static int update_main (string[] args) {
    backup_env();
    clear_env();
    file_cache_reset();
    set_env("PATH","/sbin:/bin:/usr/sbin:/usr/bin");
    if (!is_root ()) {
        error_add (_ ("You must be root!"));
        error (1);
    }
    single_instance ();
    update_repo ();
    restore_env();
    return 0;
}

private static int repo_add_main (string[] args) {
    if (get_value ("name") == "" ) {
        error_add (_ ("name not defined."));
    }else {
        string data = "";
        foreach (string arg in args) {
            data += arg + "\n";
        }
        if (args.length == 0) {
            error_add (_ ("Repository uri is not defined."));
        }
        create_dir (get_storage () + "/sources.list.d/");
        writefile (get_storage () + "/sources.list.d/" + get_value ("name"), data);
        if(get_bool("with-gpg")){
            foreach (string arg in args) {
                if(fetch(arg.replace("$uri","ymp-index.yaml.asc"), "/tmp/"+get_value ("name")+".asc")){
                    add_gpg_key("/tmp/"+get_value ("name")+".asc", get_value ("name"));
                }
            }
        }
    }
    error (1);
    return 0;
}

private static int repo_remove_main (string[] args) {
    foreach (string arg in args) {
        remove_file (get_storage () + "/sources.list.d/" + arg);
    }
    return 0;
}

private static int repo_list_main (string[] args) {
    string[] repos = find (get_storage () + "/sources.list.d/");
    repos += get_storage () + "/sources.list";
    foreach (string repofile in repos) {
        if (isfile (repofile)) {
            string fname = sbasename (repofile);
            print ("%s:".printf (colorize (fname, green)));
            foreach (string uri in ssplit (readfile (repofile), "\n")) {
                if (uri != "") {
                    print (" - " + uri);
                }
            }
        }
    }
    return 0;
}

private static int repository_main (string[] args) {
    if (get_bool ("update")) {
        return update_main (args);
    }else if (get_bool ("mirror")) {
        return mirror_main (args);
    }else if (get_bool ("index")) {
        return index_main (args);
    }else if (get_bool ("add")) {
        return repo_add_main (args);
    }else if (get_bool ("remove")) {
        return repo_remove_main (args);
    }else if (get_bool ("list")) {
        return repo_list_main (args);
    }
    return 0;
}

private static int mirror_main (string[] args) {
    string target = srealpath (get_value ("target"));
    if (target == "") {
        target=srealpath (".");
    }
    print("TARGET:"+target);
    create_dir (target);
    foreach (string arg in args) {
        foreach (repository repo in get_repos ()) {
            if (repo.name == arg || arg == "*") {
                if (!get_bool ("no-package")) {
                    foreach (string name in repo.list_packages ()) {
                        print (colorize (_ ("Mirror:"), yellow) + " " + repo.name + " => " + name + " " + _ (" (binary)"));
                        var pkg = repo.get_package (name);
                        mirror_download (pkg, target);
                    }
                }
                if (!get_bool ("no-source")) {
                    foreach (string name in repo.list_sources ()) {
                        var pkg = repo.get_source (name);
                        print (colorize (_ ("Mirror:"), yellow) + " " + repo.name + " => " + name + " " + _ (" (source)"));
                        mirror_download (pkg, target);
                    }
                }
            }
        }
    }
    if (get_bool ("index")) {
        index_main ( {target});
    }
    return 0;
}


private static void mirror_download (package pkg, string target) {
    if (pkg == null) {
         return;
    }
    string file = target + pkg.get ("uri");
    create_dir (sdirname (file));
    if (!isfile (file)) {
        fetch (pkg.get_uri (), file);
    }
}

static void repository_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (repository_main);
    op.names = {_ ("repository"), "repository", "repo"};
    op.help.name = _ ("repository");
    op.help.description = _ ("Update / Index / Mirror repository.");
    op.help.add_parameter ("--update", _ ("update repository"));
    op.help.add_parameter ("--index", _ ("index repository"));
    op.help.add_parameter ("--add", _ ("add new repository file"));
    op.help.add_parameter ("--remove", _ ("remove repository file"));
    op.help.add_parameter ("--list", _ ("list repository files"));
    op.help.add_parameter ("--mirror", _ ("mirror repository"));
    op.help.add_parameter (colorize (_ ("Index options"), magenta), "");
    op.help.add_parameter ("--move", _ ("move packages for alphabetical hierarchy"));
    op.help.add_parameter ("--name", _ ("new repository name (required)"));
    op.help.add_parameter (colorize (_ ("Add options"), magenta), "");
    op.help.add_parameter ("--name", _ ("new file name (required)"));
    op.help.add_parameter ("--with-gpg", _ ("fetch and add gpg key"));
    op.help.add_parameter (colorize (_ ("Mirror options"), magenta), "");
    op.help.add_parameter ("--no-package", _ ("do not mirror binary packages"));
    op.help.add_parameter ("--no-source", _ ("do not mirror source packages"));
    op.help.add_parameter ("--index", _ ("index after mirror."));
    op.help.add_parameter ("--target", _ ("target mirror directory"));
    add_operation (op);
}
