code_runner_plugin local;
private static void local_init(string image, string directory){
    local.ctx = directory;
    return;
}

private static int local_run(string command){
    backup_env();
    clear_env();
    set_env("PATH","/sbin:/bin:/usr/sbin:/usr/bin");
    string cur = pwd ();
    cd(local.ctx);
    int status = run_args({"sh", "-c", command});
    cd (cur);
    restore_env();
    return status;
}
private static void local_clean(){
    return;
}

public void code_runner_local_init(){
    local = new code_runner_plugin();
    local.name = "local";
    local.init.connect(local_init);
    local.run.connect(local_run);
    local.clean.connect(local_clean);
    add_code_runner_plugin(local);
}
