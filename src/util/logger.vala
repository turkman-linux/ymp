private string[] errors;
public bool enable_debug;

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

public void print(string message){
    print_fn(message,true,false);
}
public void print_stderr(string message){
    print_fn(message,true,true);
}
public string colorize(string message, int color){
    #if NOCOLOR
    if(true){
    #else
    if (!config.colorize){
    #endif
        return message;
    }else{
        return "\x1b["+color.to_string()+"m"+message+"\x1b[;0m";
    }
}

public void warning(string message){
    if (message != null){
        print_stderr(colorize("WARNING: ",yellow)+message);
    }
}

public void debug(string message){
    #if DEBUG
    if(true){
    #else
    if(enable_debug){
    #endif
        print(colorize("DEBUG: ",blue)+message);
    }
}

public void error(int status){
    foreach (string error in errors){
        stderr.printf(colorize("ERROR: ",red)+error+"\n");
    }
    if(errors.length == 0){
        return;
    }
    errors = null;
    if (status != 0){
        Process.exit (status);
    }

}
public void error_add(string message){
    if(errors == null){
        errors = {};
    }
    if (message != null){
        errors += message;
    }
}
