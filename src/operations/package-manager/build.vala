private bool no_src = false;
private static int build_operation (string[] args) {
    string current_directory=pwd ();
    string[] new_args = args;
    if (new_args.length == 0) {
        new_args = {pwd()};
    }
    foreach (string arg in new_args) {
        info (_ ("Building %s").printf (arg));
        var bd = new builder ();
        int r = bd.build_single (arg);
        if (r != 0) {
            error_add("Build path: %s (%s)".printf(bd.ymp_build.ympbuild_buildpath, arg));
            return r;
        }
        if(get_bool("install") && !get_bool("no-binary")) {
            string[] leftovers = calculate_leftover ({bd.ymp_build.get_ympbuild_value("name")});
            quarantine_import_from_path(bd.ymp_build.ympbuild_buildpath);
            quarantine_install ();
            quarantine_reset ();
            foreach (string file in leftovers) {
                remove_file (DESTDIR + "/" + file);
            }
        }
    }
    cd (current_directory);
    return 0;
}
static void build_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (build_operation);
    op.names = {_ ("build"), "build", "bi", "make"};
    op.help.name = _ ("build");
    op.help.description = _ ("Build package from ympbuild file.");
    op.help.add_parameter ("--no-source", _ ("do not generate source package"));
    op.help.add_parameter ("--no-binary", _ ("do not generate binary package"));
    op.help.add_parameter ("--no-build", _ ("do not build package (only test and package)"));
    op.help.add_parameter ("--unsafe", _ ("do not check filesystem safety"));
    op.help.add_parameter ("--no-package", _ ("do not install package after building"));
    op.help.add_parameter ("--ignore-dependency", _ ("disable dependency check"));
    op.help.add_parameter ("--no-emerge", _ ("use binary packages"));
    op.help.add_parameter ("--builddir", _ ("build directory"));
    op.help.add_parameter ("--compress", _ ("compress format"));
    op.help.add_parameter ("--install", _ ("install binary package after building"));
    add_operation (op);
}
