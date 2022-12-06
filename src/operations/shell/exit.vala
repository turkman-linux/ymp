public int exit_main(string[] args){
    int status=0;
    if(args.length > 0){
        status = int.parse(args[0]);
    }
    Process.exit(status);
}
void exit_init(){
    var h = new helpmsg();
    h.name = _("exit");
    h.description = _("Exit ymp");
    h.shell_only = true;
    add_operation(exit_main,{_("exit"),"exit","bye"},h);
}
