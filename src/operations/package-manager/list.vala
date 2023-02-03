public int list_main(string[] args) {
    if (get_bool("installed")) {
        return list_installed_main(args);
    } else if (get_bool("digraph")) {
        return list_digraph_main(args);
    } else if (get_bool("repository")) {
        return list_repository_main(args);
    } else {
        return list_available_main(args);
    }
}

public int list_installed_main(string[] args) {
    foreach(string pkg in list_installed_packages()) {
        var p = get_installed_package(pkg);
        print(colorize(pkg, green) + "\t" + p.get("description"));
    }
    return 0;
}

public int list_digraph_main(string[] args) {
    if (get_bool("digraph")) {
        print("digraph {");
        print("beautify=\"sfdp\";");
    }
    string[] group_names = {};
    foreach(repository repo in get_repos()) {
        if (args.length > 0 && !(repo.name in args)) {
            continue;
        }
        string[] names = {};
        if (get_bool("source")) {
            names = repo.list_sources();
        } else {
            names = repo.list_packages();
        }
        csort(names, names.length);
        foreach(string name in names) {
            var pkg = repo.get_package(name);
            if (pkg == null) {
                continue;
            }
            string[] deps = pkg.gets("depends");
            string color = "#";
            color += GLib.Random.int_range(31, 99).to_string();
            color += GLib.Random.int_range(31, 99).to_string();
            color += GLib.Random.int_range(31, 99).to_string();
            foreach(string dep in deps) {
                print("\"%s\" -> \"%s\" [color=\"%s\"];".printf(name, dep, color));
            }
            string[] grp = pkg.gets("group");
            foreach(string g in grp) {
                if (!(g in group_names)) {
                    group_names += g;
                }
            }
            if (is_installed_package(name)) {
                print("\"%s\" [style=filled fillcolor=\"%s\"]".printf(name,color));
            } else {
                print("\"%s\" [style=filled fillcolor=white]".printf(name));
            }
        }
    }
    if (get_bool("group")) {
        foreach(string grp in group_names) {
            print("subgraph cluster_%s {".printf(grp.replace(".", "_")));
            print("label = \"%s\";".printf(grp.replace(".", "_")));
            foreach(repository repo in get_repos()) {
                string[] names = {};
                if (get_bool("source")) {
                    names = repo.list_sources();
                } else {
                    names = repo.list_packages();
                }
                foreach(string name in names) {
                    var pkg = repo.get_package(name);
                    if (pkg == null) {
                        continue;
                    }
                    string[] gnames = pkg.gets("group");
                    if (grp in gnames) {
                        print("\"%s\";".printf(name));
                    }
                }
                print("}");
            }
        }
    }
    print("}");
    return 0;
}
public int list_available_main(string[] args) {
    if (get_bool("digraph")) {
        print("digraph {");
        print("beautify=\"sfdp\";");
    }
    foreach(repository repo in get_repos()) {
        if (args.length > 0 && !(repo.name in args)) {
            continue;
        }
        string[] names = {};
        if (get_bool("source")) {
            names = repo.list_sources();
        } else {
            names = repo.list_packages();
        }
        csort(names, names.length);
        string type = "package ";
        if (get_bool("source")) {
            type = "source ";
        }
        foreach(string name in names) {
            var pkg = repo.get_package(name);
            if (pkg == null) {
                continue;
            }
            var description = pkg.get("description");
            int color = red;
            if (is_installed_package(name)) {
                color = green;
            }
            print(repo.name + ":" + colorize(type, blue) + " " + colorize(name, color) + " " + description);
        }
    }
    return 0;
}

public int list_repository_main(string[] args) {
    foreach(repository repo in get_repos()) {
        print_fn(colorize(repo.name, green) + " :: ", false, false);
        print_fn(repo.address + " :: ", false, false);
        print_fn(colorize("(" + repo.list_packages().length.to_string() + " binary)", cyan) + " :: ", false, false);
        print_fn(colorize("(" + repo.list_sources().length.to_string() + " source) ", magenta), false, false);
        print("");

    }
    return 0;
}

void list_init() {
    var h = new helpmsg();

    h.name = _("list");
    h.description = _("List installed packages.");
    h.add_parameter("--installed", _("list installed packages"));
    h.add_parameter("--digraph", _("write as graphwiz format"));
    h.add_parameter("--repository", _("list repositories"));
    h.add_parameter("--source", _("list available source packages"));

    add_operation(list_main, {
        _("list"),
        "list",
        "ls"
    }, h);
}
