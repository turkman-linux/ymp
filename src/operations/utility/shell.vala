public int shell_main (string[] args) {
    Ymp ymp = ymp_init (args);
    if (args[0] == "-" || args.length == 0) {
        set_bool ("shellmode", true);
        while (!stdin.eof ()) {
            string prompt = colorize ("Ymp >> ", blue);
            #if no_libreadline
                print_fn (prompt, false, false);
                string line = stdin.read_line ();
            #else
                string line = Readline.readline (prompt);
            #endif
            if (line != null) {
                ymp.add_script (line);
                ymp.run ();
                ymp.clear_process ();
            }else {
                exit_main (args);
            }
        }
    }else {
        string data = readfile (args[0]);
        ymp.add_script (data);
        ymp.run ();
        ymp.clear_process ();
    }
    return 0;
}

void shell_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (shell_main);
    op.names = {_ ("shell"), "shell", "sh"};
    op.help.name = _ ("shell");
    op.help.description = _ ("Create a ymp shell or execute ympsh script.");
    add_operation (op);
}
