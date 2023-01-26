public int chroot_main(string[] args){
    if(!is_root()){
        error_add(_("You must be root!"));
        return 1;
    }
    string cmd = "";
    if(args.length > 1){
        cmd = join(" ",args[1:]);
    }else{
        cmd = "/bin/sh";
    }
    print_stderr(colorize(_("chroot: =>"),blue)+args[0]);
    run_args({"mount", "--bind", "/dev", args[0]+"/dev"});
    run_args({"mount", "--bind", "/sys", args[0]+"/sys"});
    run_args({"mount", "--bind", "/proc", args[0]+"/proc"});
    run_args({"mount", "--bind", "/run", args[0]+"/run"});
    int status = run_args({"chroot", args[0], "sh", "-c" ,cmd}) /256;
    if(status != 0){
        error_add(_("Failed to run command: %s").printf(cmd));
    }
    print_stderr(_("Command %s done.".printf(colorize(cmd,blue))));
    while( 0 == run_args({"umount", "-lf", "-R", args[0]+"/run"}));
    while( 0 == run_args({"umount", "-lf", "-R", args[0]+"/proc"}));
    while( 0 == run_args({"umount", "-lf", "-R", args[0]+"/sys"}));
    while( 0 == run_args({"umount", "-lf", "-R", args[0]+"/dev"}));
    return status;
}
void chroot_init(){
    var h = new helpmsg();
    h.name = _("chroot");
    h.description = _("Execute a command in chroot");
    h.minargs=1;
    h.shell_only = true;
    add_operation(chroot_main,{_("chroot"),"chroot"},h);
}
