private string[] errors;

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
        print_fn ("\x1b]0;" + msg + "\x07", false, false);
    }
    #endif
}

//DOC: `void error (int status):`
//DOC: print error message and exit if error message list not empty and status is not 0.
//DOC: This function clear error message list.
//DOC: This funtion must run after **error_add (string message)**
//DOC: Example usage:
//DOC: ```vala
//DOC: if (num == 12) {
//DOC:     error_add ("Number is not 12.");
//DOC: }
//DOC: error (1);
//DOC: ```
public void error (int status) {
    if (has_error ()) {
         if (!get_bool ("ignore-error")) {
            foreach (string error in errors) {
                print_stderr ("%s: %s".printf (colorize (_ ("ERROR"), red), error));
            }
        }
        errors = null;
        if (status != 0 && !get_bool ("shellmode")) {
            exit (status);
        }
    }
}
public bool has_error () {
    return errors.length != 0;
}

//DOC: `void error_add (string message):`
//DOC: add error message to error message list
public void error_add (string message) {
    if (errors == null) {
        errors = {};
    }
    if (message != null) {
        errors += message;
    }
}
