private static int kill_main (string[] args) {
    string self_link = sreadlink ("/proc/self/exe");
    int self_pid = Posix.getpid ();
    foreach (string dir in listdir ("/proc")) {
        if (int.parse (dir) != 0) {
            int pid = int.parse (dir);
            if (pid != self_pid) {
                if (issymlink ("/proc/" + dir + "/exe")) {
                    try {
                        GLib.FileUtils.read_link ("/proc/" + dir + "/exe");
                    }catch (Error e) {
                        continue;
                    }
                    string link = sreadlink ("/proc/" + dir + "/exe");
                    if (link == self_link) {
                        info (_ ("Kill: %s").printf (pid.to_string ()));
                        ckill (pid);
                    }

                }
            }
        }
    }
    return 0;
}
static void kill_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (kill_main);
    op.names = {_ ("kill"), "kill", "gg", "ğ"};
    op.help.name = _ ("kill");
    op.help.description = _ ("Kill all other ymp process.");
    add_operation (op);
}
