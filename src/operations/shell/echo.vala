public int echo_main(string[] args){
    print(join(" ",args));
    return 0;
}
void echo_init(){
    var h = new helpmsg();
    h.name = _("echo");
    h.minargs=1;
    h.description = _("Write a message to terminal.");
    h.shell_only = true;
    add_operation(echo_main,{_("echo"),"echo","print"},h);
}
