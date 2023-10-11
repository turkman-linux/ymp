//DOC: ## Process spawn funcions
//DOC: create subprocess with glib

//DOC: `int run_args (string[] args):`
//DOC: run command from argument array
public int run_args(string[] args){
    try{
        string[] env = {
            "TERM=linux",
            "PATH=/usr/bin:/bin:/usr/sbin:/sbin",
            "OPERATION="+get_value("OPERATION")
        };

        int status;
        GLib.Process.spawn_sync (pwd(),
            args,
            env,
            SpawnFlags.SEARCH_PATH,
            null,
            null,
            null,
            out status);
        return status;
    }catch(GLib.SpawnError e){
        return 127;
    }
    
}

//DOC: `int run_args (string[] args):`
//DOC: run command from argument array silently.
public int run_args_silent(string[] args){
    try{
        string[] env = {
            "TERM=linux",
            "PATH=/usr/bin:/bin:/usr/sbin:/sbin",
            "OPERATION="+get_value("OPERATION")
        };
        int status;
        string devnull;
        GLib.Process.spawn_sync (pwd(),
            args,
            env,
            SpawnFlags.SEARCH_PATH,
            null,
            out devnull,
            out devnull,
            out status);
        free(devnull);
        return status;
    }catch(GLib.SpawnError e){
        return 127;
    }
}