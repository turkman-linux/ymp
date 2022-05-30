public int clear_main(string[] args){
    stdout.printf("\x1b"+"c");
    return 0;
}
public void clear_help(){
    print_stderr("clear console");
}
