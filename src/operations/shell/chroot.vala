private static int chroot_main (string[] args) {
    if (!is_root ()) {
        error_add (_ ("You must be root!"));
        return 1;
    }
    string cmd = "";
    if (args.length > 1) {
        cmd = join (" ", args[1:]);
    }else {
        cmd = "/bin/sh";
    }
    if(!get_bool("envs")){
        backup_env();
        clear_env();
        set_env("PATH", "/sbin:/bin:/usr/sbin:/usr/bin");
    }
    print_stderr (colorize (_ ("chroot: =>"), blue) + args[0]);
    run_args_silent ( {"mount", "--bind", "/dev", args[0] + "/dev"});
    run_args_silent ( {"mount", "--bind", "/sys", args[0] + "/sys"});
    run_args_silent ( {"mount", "--bind", "/proc", args[0] + "/proc"});
    run_args_silent ( {"mount", "--bind", "/run", args[0] + "/run"});
    int status = run_args ( {"chroot", args[0], "sh", "-c" , cmd}) / 256;
    if (status != 0) {
        error_add (_ ("Failed to run command: %s").printf (cmd));
    }
    print_stderr (_ ("Command %s done.".printf (colorize (cmd, blue))));
    while ( 0 == run_args_silent ( {"umount", "-lf", "-R", args[0] + "/run"}));
    while ( 0 == run_args_silent ( {"umount", "-lf", "-R", args[0] + "/proc"}));
    while ( 0 == run_args_silent ( {"umount", "-lf", "-R", args[0] + "/sys"}));
    while ( 0 == run_args_silent ( {"umount", "-lf", "-R", args[0] + "/dev"}));
    if(!get_bool("envs")){
        restore_env();
    }
    return status;
}
void chroot_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (chroot_main);
    op.names = {_ ("chroot"), "chroot"};
    op.help.name = _ ("chroot");
    op.help.description = _ ("Execute a command in chroot.");
    op.help.minargs=1;
    op.help.shell_only = true;
    add_operation (op);
}
