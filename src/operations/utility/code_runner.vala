private static int code_runner_operation (string[] args) {
    if(get_bool("create")){
        if(args.length == 0){
            error_add(_("You must give a new file name."));
            error(2);
        }
        writefile(args[0],get_code_runner_template()+"\n\n");
        return 0;
    }else if(get_bool("trace")){
        string source = pwd ()+"build.yaml";
        if(get_value("source") != ""){
            source = get_value("source");
        }
        if(!isfile(source)){
            error_add(_("Source not found: %s").printf(source));
        }
        code_runner_trace(args[0], source);
        new MainLoop ().run ();
    }else{
        int status = code_runner_simple(args[0]);
        if(status != 0){
            return status;
        }
    }
    return 0;
}
public extern int fork();
private static int code_runner_simple(string arg){
    var crun = new code_runner();
    crun.load(arg);
    return crun.run();
}

private static int code_runner_trace (string path, string source) {
    try {
        File file = File.new_for_path (path);
        FileMonitor monitor = file.monitor (FileMonitorFlags.NONE, null);
        info("%s %s".printf(colorize("Trace:",magenta), path));
        set_value_readonly("TRACE",srealpath(path));
        monitor.changed.connect ((src, dest, event) => {
            if(get_bool("clear")){
                clear_main({});
            }
            if(event == GLib.FileMonitorEvent.ATTRIBUTE_CHANGED ||
               event == GLib.FileMonitorEvent.CHANGES_DONE_HINT ){
                return;
            }
            set_value_readonly("SOURCE",src.get_path ());
            set_value_readonly("EVENT",event.to_string ());
            print ("%s: %s".printf(event.to_string (), src.get_path ()));
            code_runner_simple(source);
        });
        new MainLoop ().run ();
    } catch (Error err) {
        print ("Error: %s\n".printf(err.message));
    }
    return 0;
}

static void code_runner_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.help.minargs=1;
    op.callback.connect (code_runner_operation);
    op.names = {_ ("code-runner"), "code-runner", "cdrn"};
    op.help.name = _ ("code-runner");
    op.help.description = _ ("Run code-runner jobs.");
    add_operation (op);
}
