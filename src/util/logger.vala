private string[] errors;

//DOC: ## logging functions

//DOC: `void print(string message):`
//DOC: write standard messages to stdout
//DOC: Example usage:
//DOC: ```vala
//DOC: print("Hello world!");
//DOC: ```
public extern void print(string msg);
//DOC: `void warning(string message):`
//DOC: write warning message like this:
//DOC: ```yaml
//DOC: WARNING: message
//DOC: ```
public extern void warning(string msg);
//DOC: `void debug(string message):`
//DOC: write debug messages. Its only print if debug mode enabled.
public extern void debug(string msg);
//DOC: `void info(string message):`
//DOC: write additional info messages.
public extern void info(string msg);

//DOC: `string colorize(string message, int color):`
//DOC: Change string color if no_color is false.
//DOC: Example usage:
//DOC: ```vala
//DOC: var msg = colorize("Hello",red);
//DOC: var msg2 = colorize("world",blue);
//DOC: stdout.printf(msg+" "+msg2);
//DOC: ```
public string colorize(string msg, int color){
    return ccolorize(msg, color.to_string());
}

//DOC: `void print_stderr(string message):`
//DOC: same with print but write to stderr
public extern void print_stderr(string msg);

public void warning_fn(string message){
    print_stderr(colorize("WARNING: ",yellow)+message);
}

public void debug_fn(string message){
    print_stderr(colorize("DEBUG: ",blue)+message);
}

public void info_fn(string message){
    print_stderr(colorize("INFO : ",green)+message);
}

public string colorize_fnx(string msg, int color){
    return ccolorize(msg,color.to_string());
}
public string colorize_dummy(string msg, int color){
    return msg;
}


public extern void logger_init();


//DOC: `void set_terminal_title(string msg):`
//DOC: set terminal title
public void set_terminal_title(string msg){
    #if NOCOLOR
       return;
    #else
    if (!get_bool("no-color")){
        print_fn("\x1b]0;"+msg+"\x07",false,false);
    }
    #endif
}

//DOC: `void error(int status):`
//DOC: print error message and exit if error message list not empty and status is not 0.
//DOC: This function clear error message list.
//DOC: This funtion must run after **error_add(string message)**
//DOC: Example usage:
//DOC: ```vala
//DOC: if(num == 12){
//DOC:     error_add("Number is not 12.");
//DOC: }
//DOC: error(1);
//DOC: ```
public void error(int status){
    if(has_error()){
         if(!get_bool("ignore-error")){
            foreach (string error in errors){
                print_stderr(colorize("ERROR: ",red)+error);
            }
        }
        errors = null;
        if (status != 0 && !get_bool("shellmode")){
            Process.exit (status);
        }
    }
}
public bool has_error(){
    return errors.length != 0;
}

//DOC: `void error_add(string message):`
//DOC: add error message to error message list
public void error_add(string message){
    if(errors == null){
        errors = {};
    }
    if (message != null){
        errors += message;
    }
}
