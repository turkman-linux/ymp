//DOC: ## Colors
//DOC: Available colors;
//DOC: black, red, green, yellow, blue, magenta, cyan, white;
public int black = 30;
public int red = 31;
public int green = 32;
public int yellow = 33;
public int blue = 34;
public int magenta = 35;
public int cyan = 36;
public int white = 37;

//DOC: `string colorize(string message, int color):`;
//DOC: Change string color if no_color is false.;
//DOC: Example usage:;
//DOC: ```vala
//DOC: var msg = colorize("Hello",red); 
//DOC: var msg2 = colorize("world",blue); 
//DOC: stdout.printf(msg+" "+msg2); 
//DOC: ```;
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

