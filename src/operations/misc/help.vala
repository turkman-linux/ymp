public int help_main(string[] args){
    if (args.length == 0){
        print_fn(colorize("Operation list: ",blue), false, false);
        foreach(operation op in ops){
            print_fn(join(" ",op.names)+"\n", false, false);
        }
    }else{
        foreach(string arg in args){
            foreach(operation op in ops){
                if(arg in op.names){
                    write_op_help(op);
                }
            }
        }
    
    }
    return 0;
}

private void write_op_help(operation op){
    print_fn(op.help.build(),false,true);
}
void help_init(){
    var h = new helpmsg();
    h.name = "help";
    h.description = "Write help message about ymp commands.";
    add_operation(help_main,{"help"},h);
}

public class helpmsg{
    public string description="";
    private string[] parameters;
    public string name="";
    public string usage="";
    public int minargs = 0;
    
    public void add_parameter(string arg, string desc){
        if (parameters == null){
            parameters = {};
        }
        string f = (colorize(arg,red)+" : "+desc);
        parameters += f;
    }
    public string build(){
        string ret = "";
        if(usage == ""){
            usage = "ymp "+name+" [OPTION]... [ARGS]... ";
        }
        ret += colorize("Usage: ",green)+usage+"\n";
        ret += description + "\n";
        if(parameters.length > 0){
            ret += colorize("Options:\n",green);
            foreach(string param in parameters){
                ret += "  "+param+"\n";
            }
        }
        return ret;
    }
}
