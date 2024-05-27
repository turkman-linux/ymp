
//DOC: ## logging functions

//DOC: `void print (string message):`
//DOC: write standard messages to stdout
//DOC: Example usage:
//DOC: ```vala
//DOC: print ("Hello world!");
//DOC: ```
public extern void print (string msg);
//DOC: `void warning (string message):`
//DOC: write warning message like this:
//DOC: ```yaml
//DOC: WARNING: message
//DOC: ```
public extern void warning (string msg);
#if DEBUG
//DOC: `void debug (string message):`
//DOC: write debug messages. Its only print if debug mode enabled.
public extern void debug (string msg);
//DOC: `void info (string message):`
//DOC: write additional info messages.
#endif
public extern void info (string msg);

//DOC: `void print_stderr (string message):`
//DOC: same with print but write to stderr
public extern void print_stderr (string msg);

public void warning_fn (string message) {
    print_stderr ("%s: %s".printf (colorize (_ ("WARNING"), yellow), message));
}

#if DEBUG
private long last_debug_time = -1;
public void debug_fn (string message) {
    if (last_debug_time == -1) {
        last_debug_time = get_epoch();
    }
    print_stderr ("[%s:%d]: %s".printf (colorize (_ ("DEBUG"), blue), (int) (get_epoch () - last_debug_time) , message));
    last_debug_time = get_epoch();
}
#endif

public void info_fn (string message) {
    print_stderr ("%s: %s".printf (colorize (_ ("INFO"), green), message));
}

public extern void logger_init ();


//DOC: `void set_terminal_title (string msg):`
//DOC: set terminal title
public void set_terminal_title (string msg) {
    #if NOCOLOR
       return;
    #else
    if (!get_bool ("no-color")) {
        print_fn ("\x1b]2;" + msg + "\x07", false, false);
    }
    #endif
}

