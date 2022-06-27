public int run_sandbox_main(string[] args){
    sandbox_network = true;
    clear_env();
    set_env("PATH","/bin:/usr/bin:/sbin:/usr/sbin");
    int status = sandbox(args);
    return status/256;
}

void run_sandbox_init(){
    add_operation(run_sandbox_main,{"sandbox", "sb"});
}
