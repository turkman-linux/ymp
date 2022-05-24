int red = 31;
int yellow = 33;
int blue = 34;

logger log;

public class logger {
    bool nocolor = false;
    string[] errors= {};
    public bool enable_debug;

    public void print(string message){
        if (message != null){
            stdout.printf(message+"\n");
        }
    }

    public string colorize(string message, int color){
        if (nocolor){
            return message;
        }else{
            return "\x1b["+color.to_string()+"m"+message+"\x1b[;0m";
        }
    }

    public void warning(string message){
        if (message != null){
            print(colorize(message,yellow));
        }
    }

    public void debug(string message){
        if(enable_debug){
            print(colorize(message,blue));
        }
    }

    public void error(int status){
        foreach (string error in errors){
            stderr.printf(colorize(error,red)+"\n");
        }
        if (status != 0){
            Process.exit (status);
        }else{
            errors = {};
        }
    }
    public void error_add(string message){
        if (message != null){
            errors += message;
        }
    }
}
