private bool no_src = false;
private static int build_operation (string[] args) {
    string current_directory=pwd ();
    string[] new_args = args;
    if (usr_is_merged ()) {
        error_add (_ ("Build operation with usrmerge is not allowed!"));
        error (31);
    }
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
    }
    cd (current_directory);
    return 0;
}
void build_init () {
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
