private string[] errors;

//DOC: ## logging functions
//DOC: `void print_fn(string message, bool new_line, bool err):`;
//DOC: Main print function. Has 3 arguments;
//DOC: * message: log message
//DOC: * new_line: if set true, append new line
//DOC: * err: if set true, write log to stderr
public void print_fn(string message, bool new_line, bool err){
    if (message != null){
        string nl="";
        if(new_line){
            nl="\n";
        }
        if(message == ""){
            return;
        }
        if(err){
            stderr.printf(message+nl);
            stderr.flush();
        }else{
            stdout.printf(message+nl);
            stderr.flush();
        }
    }
}

//DOC: `void print(string message):`;
//DOC: write standard messages to stdout;
//DOC: Example usage:;
//DOC: ```vala
//DOC: print("Hello world!"); 
//DOC: ```;
public void print(string message){
    print_fn(message,true,false);
}

//DOC: `void print_stderr(string message):`;
//DOC: same with print but write to stderr;
public void print_stderr(string message){
    print_fn(message,true,true);
}

//DOC: `void warning(string message):`;
//DOC: write warning message like this:;
//DOC: ```yaml
//DOC: WARNING: message
//DOC: ```;
public void warning(string message){
    if (message != null){
        print_stderr(colorize("WARNING: ",yellow)+message);
    }
}

//DOC: `void debug(string message):`;
//DOC: write debug messages. Its only print if debug mode enabled.;
public void debug(string message){
    #if DEBUG
    if(true){
    #else
    if(get_bool("debug")){
    #endif
        print_fn(colorize("DEBUG: ",blue)+message,true,true);
    }
}

//DOC: `void error(int status):`;
//DOC: print error message and exit if error message list not empty and status is not 0.;
//DOC: This function clear error message list.;
//DOC: This funtion must run after **error_add(string message)**;
//DOC: Example usage:;
//DOC: ```vala
//DOC: if(num == 12){
//DOC:     error_add("Number is not 12."); 
//DOC: }
//DOC: error(1);
//DOC: ```;
public void error(int status){
    foreach (string error in errors){
        stderr.printf(colorize("ERROR: ",red)+error+"\n");
    }
    if(errors.length == 0){
        return;
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
