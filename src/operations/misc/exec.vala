public int exec_main(string[] args){
    string cmd = join(" ",args);
    print_stderr(colorize("Executing: =>",blue)+cmd);
    int status = 0;
    if(get_bool("quiet")){
        status = run_silent(cmd);
    }else{
        status = run(cmd);
    }
    if(status != 0){
        error_add(@"Failed to run command $cmd");
    }
    print_fn("Command "+colorize(@"$cmd",blue)+" done.",true,true);
    return status;
}
void exec_init(){
    var h = new helpmsg();
    h.name = "exec";
    h.description = "Execute a command";
    h.add_parameter("--quiet","run without output");
    add_operation(exec_main,{"exec"},h.build());
}
