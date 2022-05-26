public int help_main(string[] args){
    if(args.length == 0){
        string msg="Operation not selected" + "\n";
        msg += "Available operations:";
        foreach(string op in operation_names){
            msg += "\n  " + op;
        }
        error_add(msg);
        error(1);
    }
    foreach(string arg in args){
        if(arg == "all"){
            help();
            continue;
        }
        operation_help(arg);
    }
    return 0;
}
public void help(){
    foreach(string op in operation_names){
        operation_help(op);
    }
}
public void help_help(){
    print_stderr("write help");
}
