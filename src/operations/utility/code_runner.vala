public int code_runner_operation (string[] args) {
    if(get_bool("create")){
        writefile(args[0],get_code_runner_template()+"\n\n");
        return 0;
    }
    foreach (string arg in args){
        var crun = new code_runner();
        crun.load(arg);
        int status = crun.run();
        if(status != 0){
            return status;
        }
    }
    return 0;
}

void code_runner_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (code_runner_operation);
    op.names = {_ ("code-runner"), "code-runner", "cdrn"};
    op.help.name = _ ("code-runner");
    op.help.description = _ ("Run code-runner jobs.");
    add_operation (op);
}
