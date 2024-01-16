private static int info_main(string[] args) {
    foreach(string arg in args) {
        if (get_bool("deps")) {
            bool ri = get_bool("reinstall");
            set_bool("reinstall", true);
            string[] required = resolve_dependencies({arg});
            print(join(" ", required));
            set_bool("reinstall", ri);
        } else if (get_bool("revdeps")) {
            bool ri = get_bool("reinstall");
            set_bool("reinstall", true);
            string[] required = resolve_reverse_dependencies({arg});
            print(join(" ", required));
            set_bool("reinstall", ri);
        } else {
            package p = get_package(arg);
            if (p == null) {
                continue;
            }
            if (get_value("get") != "") {
                print("%s: %s".printf(get_value("get"), p.get(get_value("get"))));
            } else {
                if (p.is_source) {
                    print("source:");
                } else {
                    print("package:");
                }
                print("  name: %s".printf(p.name));
                print("  version: %s".printf(p.version));
                print("  release: %d".printf(p.release));
                if(p.dependencies.length > 0){
                    print("  depends: ");
                    foreach(string dep in p.dependencies){
                        print("    - %s".printf(dep));
                    }
                }
                if(p.gets("use-flags").length > 0){
                    print("  use_flags:");
                    foreach(string flag in p.gets("use-flags")){
                        print("    - %s".printf(flag));

                    }
                }
                if(p.gets("group").length > 0){
                    print("  groups:");
                    foreach(string group in p.gets("group")){
                        print("    - %s".printf(group));

                    }
                }
                print("  is_installed: %s".printf(p.is_installed().to_string()));
                print("  remote_url: %s".printf(p.get_uri()));

            }
        }
    }
    return 0;
}

static void info_init() {
    operation op = new operation();
    op.help = new helpmsg();
    op.callback.connect(info_main);
    op.names = {
        _("info"),
        "info",
        "i"
    };
    op.help.name = _("info");
    op.help.description = _("Get informations from package manager databases.");
    op.help.add_parameter("--deps", _("list required packages"));
    op.help.add_parameter("--revdeps", _("list packages required by package"));
    add_operation(op);
}
