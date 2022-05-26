public int echo_main(string[] args){
    foreach(string arg in args){
        print_fn(arg+" ",false,false);
    }
    print("");
    return 0;
}
public void echo_help(){
    print_stderr("write string to console");
}
