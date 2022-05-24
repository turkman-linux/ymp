using Posix;
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

public static int run_silent (string command) {
    string stdout;
    string stderr;
    int status;
    try {
        Process.spawn_command_line_sync (command, out stdout, out stderr, out status);
        return status;
    } catch (SpawnError e) {
        return 1;
    }
}

public int run (string command){
    return Posix.system(command);
}
