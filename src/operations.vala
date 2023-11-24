private operation[] ops;
private class operation {
    public signal int callback (string[] args);
    public string[] names;
    public helpmsg help;
}

private void add_operation (operation op) {
    debug (_ ("Add operation: %s").printf (join (":", op.names)));
    ops += op;
}

private void lock_operation () {
    block_sigint ();
    if (get_bool ("unblock")) {
        unblock_sigint ();
    }
}
private void unlock_operation () {
    unblock_sigint ();
}

public int operation_main(string type, string[] args){
    if(get_bool("sandbox") && !isfile("/.sandbox")){
        info (_ ("RUN (SANDBOX):") + type + ":" + join (" ", args));
        sandbox_shared = get_value ("shared");
        sandbox_tmpfs = get_value ("tmpfs");
        sandbox_rootfs = get_destdir ();
        sandbox_uid = int.parse (get_value ("uid"));
        sandbox_gid = int.parse (get_value ("gid"));
        return sandbox(type, args);
    }
    info (_ ("RUN:") + type + ":" + join (" ", args));
    string[] new_args = {};
    bool e = false;
    for(int i=0;args[i] != null;i++){
        string arg = args[i];
        if (startswith(arg,"$(") && endswith(arg,")")){
            arg = getoutput(arg[2:-1]).strip();
        }else if (arg.length > 1 && arg[0] == '$') {
            arg = get_value (arg[1:]);
        }
        foreach(string name in get_variable_names()){
            if("${%s}".printf(name) in arg){
                arg = arg.replace("${%s}".printf(name), get_value(name));
            }
        }
        if(arg == "--"){
            e = true;
            continue;
        }
        if(!e && startswith(arg,"--")){
            continue;
        }
        new_args += arg;
    }
    debug (_ ("RUN:") + type + ":" + join (" ", new_args));
    foreach (operation op in ops) {
        foreach (string name in op.names) {
            if (type == name) {
                if (get_bool ("help") || op.help.minargs > new_args.length) {
                    return help_main ({name});
                }
                set_value_readonly ("OPERATION", op.help.name);
                return op.callback (new_args);
            }
        }
    }
    warning (_ ("Invalid operation name: %s").printf (type));
    return 0;
}

