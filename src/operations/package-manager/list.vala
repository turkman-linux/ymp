private static int list_main(string[] args) {
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

private static int list_installed_main(string[] args) {
    foreach(string pkg in list_installed_packages()) {
        var p = get_installed_package(pkg);
        print(colorize(pkg, green) + "\t" + p.get("description"));
    }
    return 0;
}

private static int list_digraph_main(string[] args) {
    if (get_bool("digraph")) {
        print("digraph {");
        print("rankdir=LR;");
        print("splines = true;");
        print("overlap = false;");
    }
    string[] group_names = {};
    if (get_bool("repository")) {
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
            csort(names);
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
                    print("\"%s\" [style=filled fillcolor=\"%s\"]".printf(name, color));
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
    } else {
        bool reinstall = get_bool("reinstall");
        set_bool("reinstall", true);
        foreach(string arg in args) {
            package pi = get_package(arg);
            foreach(string dep in pi.dependencies) {
                string color = "#";
                color += GLib.Random.int_range(31, 99).to_string();
                color += GLib.Random.int_range(31, 99).to_string();
                color += GLib.Random.int_range(31, 99).to_string();
                print("\"%s\" -> \"%s\" [color=\"%s\"];".printf(arg, dep, color));
            }
            foreach(string name in resolve_dependencies({arg})) {
                if (!is_installed_package(name)) {
                    continue;
                }
                package p = get_package(name);
                if (p == null) {
                    continue;
                }
                foreach(string dep in p.dependencies) {
                    if ("|" in dep) {
                        foreach(string fname in ssplit(dep, "|")) {
                            if (is_installed_package(fname)) {
                                dep = fname;
                                break;
                            }
                        }
                    }
                    string color = "#";
                    color += GLib.Random.int_range(31, 99).to_string();
                    color += GLib.Random.int_range(31, 99).to_string();
                    color += GLib.Random.int_range(31, 99).to_string();
                    print("\"%s\" -> \"%s\" [color=\"%s\"];".printf(name, dep, color));
                }
            }
        }
        set_bool("reinstall", reinstall);
    }
    print("}");
    return 0;
}
private static int list_available_main(string[] args) {
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
        csort(names);
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

private static int list_repository_main(string[] args) {
    foreach(repository repo in get_repos()) {
        string[] srcs = repo.list_sources();
        string[] pkgs = repo.list_packages();
        print_fn(colorize(repo.name, green) + " :: ", false, false);
        print_fn(repo.address + " :: ", false, false);
        print_fn(colorize(" (" + pkgs.length.to_string() + " binary)", cyan) + " :: ", false, false);
        print_fn(colorize(" (" + srcs.length.to_string() + " source) ", magenta), false, false);
        print("");
        if (!get_bool("ignore-check")) {
            string[] cache = {};
            foreach(string pkg in pkgs) {
                if (!(pkg in srcs)) {
                    warning(_("Source package is not available: %s").printf(pkg));
                }
                if (pkg in cache) {
                    warning(_("A package has multiple versions: %s").printf(pkg));
                }
                cache += pkg;
            }
            cache = {};
            foreach(string src in srcs) {
                if (!(src in pkgs)) {
                    warning(_("Binary package is not available: %s").printf(src));
                }
                if (src in cache) {
                    warning(_("A source has multiple versions: %s").printf(src));
                }
                cache += src;
            }
        }
    }
    return 0;
}

static void list_init() {
    operation op = new operation();
    op.help = new helpmsg();
    op.callback.connect(list_main);
    op.names = {
        _("list"),
        "list",
        "ls"
    };
    op.help.name = _("list");
    op.help.description = _("List installed packages.");
    op.help.add_parameter("--installed", _("list installed packages"));
    op.help.add_parameter("--digraph", _("write as graphwiz format"));
    op.help.add_parameter("--repository", _("list repositories"));
    op.help.add_parameter("--source", _("list available source packages"));

    add_operation(op);
}
