public int exit_main(string[] args){
    int status=0;
    if(args.length > 0){
        status = int.parse(args[0]);
    }
    Process.exit(status);
}
void exit_init(){
    add_operation(exit_main,{"exit","bye"});
}
