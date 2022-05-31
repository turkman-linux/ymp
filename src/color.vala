public int red = 31;
public int yellow = 33;
public int blue = 34;

public string colorize(string message, int color){
    #if NOCOLOR
    if(true){
    #else
    if (get_bool("no_color")){
    #endif
        return message;
    }else{
        return "\x1b["+color.to_string()+"m"+message+"\x1b[;0m";
    }
}

