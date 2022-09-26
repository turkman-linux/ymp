public int exec_main(string[] args){
    string cmd = join(" ",args);
    print_stderr(colorize("Executing: =>",blue)+cmd);
    if(get_bool("daemon")){
        cmd+=" &";
    }
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
    add_operation(exec_main,{"exec"},"Execute command.");
}
