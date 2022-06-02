public int exec_main(string[] args){
    string cmd = "";
    foreach(string arg in args){
        cmd += arg+" ";
    }
    print_stderr(colorize("Executing: =>",blue)+cmd);
    int status = run(cmd);
    if(status != 0){
        error_add(@"Failed to run command $cmd");
    }
    return status;
}
public void exec_init(){
    add_operation(exec_main,{"exec"});
}
