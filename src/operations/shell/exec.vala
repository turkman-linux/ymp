public int exec_main(string[] args){
    string cmd = join(" ",args);
    print_stderr(colorize(_("Executing: =>"),blue)+cmd);
    int status = 0;
    if(get_destdir() != "/"){
        status = run_args({"chroot", get_destdir(), cmd}) /256;
    }else if(get_bool("silent")){
        status = run(cmd+" 2>/dev/null | :") /256;
    }else{
        status = run(cmd)/256;
    }
    if(status != 0){
        error_add(_("Failed to run command: %s").printf(cmd));
    }
    print_stderr(_("Command %s done.".printf(colorize(cmd,blue))));
    return status;
}
void exec_init(){
    var h = new helpmsg();
    h.name = _("exec");
    h.description = _("Execute a command.");
    h.minargs=1;
    h.shell_only = true;
    h.add_parameter("--silent",_("run without output"));
    add_operation(exec_main,{_("exec"),"exec"},h);
}
