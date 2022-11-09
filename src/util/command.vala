using Posix;
//DOC: ## Command functions
//DOC: This functions call shell commands
//DOC: Example usage
//DOC: ```vala
//DOC: if (0 != run("ls /var/lib/ymp")){
//DOC:     stdout.printf("Command failed");
//DOC: }
//DOC: string uname = getoutput("uname");
//DOC: ```

//DOC: `string getoutput (string command):`
//DOC: Run command and return output
//DOC: **Note:** stderr ignored.
public static string getoutput (string command) {
    string stdout;
    string stderr;
    int status;
    try {
        Process.spawn_command_line_sync (command, out stdout, out stderr, out status);
        return stdout;
    } catch (SpawnError e) {
        return "";
    }
}


//DOC: `int run_silent(string command):`
//DOC: run command silently.
public static int run_silent (string command) {
    string stdout;
    string stderr;
    int status;
    try {
        Process.spawn_command_line_sync (command, out stdout, out stderr, out status);
        return status/256;
    } catch (SpawnError e) {
        return 1;
    }
}

//DOC: `int run_args(string[] args):`
//DOC: ruh command from argument array
public int run_args(string[] args){
    string stdout;
    string stderr;
    string[] spawn_env = Environ.get ();
    int status;
    try {
        Process.spawn_sync ("/", args, spawn_env, SpawnFlags.SEARCH_PATH, null, out stdout, out stderr, out status);
        return status/256;
    } catch (SpawnError e) {
        return 1;
    }
}

//DOC: `int run_args(string[] args):`
//DOC: ruh command from argument array
public string getoutput_args(string[] args){
    string stdout;
    string stderr;
    string[] spawn_env = Environ.get ();
    int status;
    try {
        Process.spawn_sync ("/", args, spawn_env, SpawnFlags.SEARCH_PATH, null, out stdout, out stderr, out status);
        return stdout;
    } catch (SpawnError e) {
        return "";
    }
}
