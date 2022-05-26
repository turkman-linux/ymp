public int echo_main(string[] args){
    foreach(string arg in args){
        print_fn(arg+" ",false,false);
    }
    print("");
    return 0;
}
