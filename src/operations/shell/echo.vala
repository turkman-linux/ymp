public int echo_main(string[] args){
    print(join(" ",args));
    return 0;
}
void echo_init(){
    var h = new helpmsg();
    h.name = "echo";
    h.minargs=1;
    h.description = "Write a message to terminal.";
    h.shell_only = true;
    add_operation(echo_main,{"echo","print"},h);
}
