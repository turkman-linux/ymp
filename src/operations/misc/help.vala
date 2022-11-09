public int help_main(string[] args){
    if (args.length == 0){
        write_version();
        print(colorize("Operation list: ",blue));
        foreach(operation op in ops){
            print_fn(colorize(join(" ",op.names)+" : ",green)+op.help.description+"\n", false, false);
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

public void write_version(){
    print("YMP : "+colorize("Y",red)+"erli ve "+colorize("M",red)+"illi "+colorize("P",red)+"ackage manager");
    print("Version : "+VERSION);
    print("");
    string flag =
"            /#&@@@@@@&#*                              
        *%@@@@@@@@@@@@@@@@@@@&#*                      
     *&@@@@@@@@@@&(/*       **/#&%                    
   /&@@@@@@@@@#*                  /(*                 
 *#@@@@@@@@@/                            **           
 &@@@@@@@@#*                             *%&(         
%@@@@@@@@#                               *%@@&/*/#&@% 
@@@@@@@@&/                             **(&@@@@@@@%*  
@@@@@@@@&*                         *#&@@@@@@@@@@@%    
@@@@@@@@@(                               *%@@@@@@@@#  
(@@@@@@@@&*                              *%@@(   **(%/
 (@@@@@@@@&/                             *##*         
  /@@@@@@@@@&*                      *                 
    (@@@@@@@@@@#*                /#(                  
      *&@@@@@@@@@@@&#(//**//(%@@%                     
          (&@@@@@@@@@@@@@@@@%/                        ";
    foreach(string line in ssplit(flag,"\n")){
        print("    "+line);
    }
    print("");
}

private void write_op_help(operation op){
    print(op.help.build());
}
void help_init(){
    add_common_parameter("--","stop argument parser");
    #if check_oem
    add_common_parameter("--allow-oem","disable oem check");
    #endif
    add_common_parameter("--quiet","disable output");
    add_common_parameter("--ignore-warning","disable warning messages");
    #if DEBUG
    add_common_parameter("--debug","enable debug output");
    #endif
    add_common_parameter("--verbose","show verbose output");
    add_common_parameter("--ask","enable questions");
    add_common_parameter("--no-color","disable color output");
    add_common_parameter("--no-sysconf","disable sysconf triggers");
    add_common_parameter("--sandbox","run ymp actions at sandbox environment");
    add_common_parameter("--help","write help messages");


    var h = new helpmsg();
    h.name = "help";
    h.description = "Write help message about ymp commands.";
    add_operation(help_main,{"help"},h);
    
}

private string[] common_parameters;
private void add_common_parameter(string arg, string desc){
    if(common_parameters == null){
        common_parameters = {};
    }
    common_parameters += (colorize(arg,red)+" : "+desc);
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
        ret += colorize("Common options:\n",green);
        foreach(string param in common_parameters){
            ret += "  "+param+"\n";
        }
        return ret;
    }
}
