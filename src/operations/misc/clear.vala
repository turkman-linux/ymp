public int clear_main(string[] args){
    stdout.printf("\x1b"+"c");
    return 0;
}
void clear_init(){
    var h = new helpmsg();
    h.name = "clear";
    h.description = "Clear terminal screen.";
    add_operation(clear_main,{"clear"},h.build());
}
