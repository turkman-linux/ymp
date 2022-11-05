private string[] errors;

//DOC: ## logging functions
public delegate void logger(string message);
public delegate string fncolor(string msg, int color);

//DOC: `void print(string message):`
//DOC: write standard messages to stdout
//DOC: Example usage:
//DOC: ```vala
//DOC: print("Hello world!");
//DOC: ```
public logger print;


//DOC: `void print_stderr(string message):`
//DOC: same with print but write to stderr
public logger print_stderr;


//DOC: `void warning(string message):`
//DOC: write warning message like this:
//DOC: ```yaml
//DOC: WARNING: message
//DOC: ```
public logger warning;

//DOC: `void debug(string message):`
//DOC: write debug messages. Its only print if debug mode enabled.
public logger debug;



//DOC: `void info(string message):`
//DOC: write additional info messages.
public logger info;


//DOC: `string colorize(string message, int color):`
//DOC: Change string color if no_color is false.
//DOC: Example usage:
//DOC: ```vala
//DOC: var msg = colorize("Hello",red);
//DOC: var msg2 = colorize("world",blue);
//DOC: stdout.printf(msg+" "+msg2);
//DOC: ```
public fncolor colorize;

private void warning_fn(string message){
    print_stderr(colorize("WARNING: ",yellow)+message);
}

private void debug_fn(string message){
    print_fn(colorize("DEBUG: ",blue)+message,true,true);
}

private void info_fn(string message){
    print(colorize("INFO: ",green)+message);
}

private string colorize_fn(string msg, int color){
    return ccolorize(msg,color.to_string());
}
private string colorize_dummy(string msg, int color){
    return msg;
}

private void logger_init(){
    if(get_bool("quiet")){
        print = cprint_dummy;
        print_stderr = cprint_dummy;
    }else{
        print = cprint;
        print_stderr = cprint_stderr;
        
    }
    if(get_bool("ignore-warning")){
        warning = cprint_stderr;
    }else{
        warning = warning_fn;
    }
    #if DEBUG
    if(get_bool("debug")){
        debug = debug_fn;
    }else{
        debug = cprint_dummy;
    }
    #else
    debug = cprint_dummy;
    #endif
    if(get_bool("verbose")){
        info = info_fn;
    }else{
        info = cprint_dummy;
    }
    if (get_bool("no-color")){
        colorize = colorize_dummy;
    }else{
        colorize = colorize_fn;
    }
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
    if(errors.length == 0){
        return;
    }
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
