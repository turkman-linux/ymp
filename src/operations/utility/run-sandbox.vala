public int run_sandbox_main(string[] args){
    if(!get_bool("no-net")){
        sandbox_network = true;
    }
    clear_env();
    sandbox_shared = get_value("shared");
    sandbox_rootfs = get_destdir();
    int status = sandbox(args);
    return status/256;
}

void run_sandbox_init(){
    add_operation(run_sandbox_main,{"sandbox", "sb"});
}
