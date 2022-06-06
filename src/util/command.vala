using Posix;
//DOC: ## Command functions
//DOC: This functions call shell commands;
//DOC: Example usage:
//DOC: ```vala
//DOC: if (0 != run("ls /var/lib/inary")){
//DOC:     stdout.printf("Command failed");
//DOC: }
//DOC: string uname = getoutput("uname");
//DOC: ```;


//DOC: `string getoutput (string command):`;
//DOC: Run command and return output;
//DOC: **Note:** stderr ignored.;
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

//DOC: `int run_silent(string command):`;
//DOC: run command silently.;
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

//DOC: `int run(string command):`;
//DOC: run command.;
public int run (string command){
    return Posix.system(command)/256;
}
