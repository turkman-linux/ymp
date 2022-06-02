public int clear_main(string[] args){
    stdout.printf("\x1b"+"c");
    return 0;
}
public void clear_init(){
    add_operation(clear_main,{"clear"});
}
