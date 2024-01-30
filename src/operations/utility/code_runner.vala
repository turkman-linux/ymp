private static int code_runner_operation (string[] args) {
    if(get_bool("create")){
        if(args.length == 0){
            error_add(_("You must give a new file name."));
            error(2);
        }
        writefile(args[0],get_code_runner_template()+"\n\n");
        return 0;
    }else{
        int status = code_runner_simple(args[0]);
        if(status != 0){
            return status;
        }
    }
    return 0;
}

private static int code_runner_simple(string arg){
    var crun = new code_runner();
    crun.load(arg);
    return crun.run();
}

static void code_runner_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.help.minargs=1;
    op.callback.connect (code_runner_operation);
    op.names = {_ ("code-runner"), "code-runner", "cdrn"};
    op.help.name = _ ("code-runner");
    op.help.add_parameter ("--create", _ ("create new from template"));
    op.help.add_parameter ("--plugindir", _ ("plugin directory"));
    op.help.description = _ ("Run code-runner jobs.");
    add_operation (op);
}
