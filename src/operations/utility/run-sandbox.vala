public int run_sandbox_main (string[] args) {
    if (usr_is_merged ()) {
        error_add (_ ("Sandbox operation with usrmerge is not allowed!"));
        error (31);
    }
    if (!get_bool ("no-net")) {
        sandbox_network = true;
    }
    sandbox_shared = get_value ("shared");
    sandbox_tmpfs = get_value ("tmpfs");
    sandbox_rootfs = get_destdir ();
    sandbox_uid = int.parse (get_value ("uid"));
    sandbox_gid = int.parse (get_value ("gid"));
    info (_ ("Execute sandbox :%s").printf (join (" ", args)));
    int status = sandbox (args);
    return status / 256;
}

void run_sandbox_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (run_sandbox_main);
    op.names = {_ ("sandbox"), "sandbox", "sb"};
    op.help.name = _ ("sandbox");
    op.help.minargs=1;
    op.help.description = _ ("Start sandbox environment.");
    op.help.add_parameter ("--shared", _ ("select shared directory"));
    op.help.add_parameter ("--tmpfs", _ ("select tmpfs directory"));
    op.help.add_parameter ("--no-net", _ ("block network access"));
    add_operation (op);
}
