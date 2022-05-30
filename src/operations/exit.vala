public int exit_main(string[] args){
    int status=0;
    if(args.length > 0){
        status = int.parse(args[0]);
    }
    Process.exit(status);
}
public void exit_help(){
    print_stderr("exit inary");
}
