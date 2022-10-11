public int run_sandbox_main(string[] args){
    if(!get_bool("no-net")){
        sandbox_network = true;
    }
    clear_env();
    sandbox_shared = get_value("shared");
    sandbox_rootfs = get_destdir();
    sandbox_uid = int.parse(get_value("uid"));
    sandbox_gid = int.parse(get_value("gid"));
    int status = sandbox(args);
    return status/256;
}

void run_sandbox_init(){
    var h = new helpmsg();
    h.name = "sandbox";
    h.description = "Start sandbox environment.";
    h.add_parameter("--shared","select shared directory");
    h.add_parameter("--no-net","block network access");
    add_operation(run_sandbox_main,{"sandbox", "sb"},h);
}
