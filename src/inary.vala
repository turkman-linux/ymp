public class operation{
    public string type;
    public string[] args;
    
    public int run(){
        if(type == null){
            return 0;
        }
        if(args == null){
            args = {};
        }
        return operation_main(get_alias_type(type),args);
    }
}
public class Inary {
    operation[] process;
    
    public void add_process(string type, string[] args){
        if(process == null){
            process = {};
        }
        if(type == null){
           return;
        }
        operation op = new operation();
        op.type = type;
        op.args = args;
        process += op;
    }
    public void clear_process(){
        process = {};
    }
    public void run(){
        for(int i=0;i<process.length;i++){
            int status = process[i].run();
            if(status != 0){
                string type = process[i].type;
                error_add(@"Process: $type failed. Exited with $status.");
                error(status);
            }
        }
        error(1);
    }
    public void add_script(string data){
        if(data == null){
            return;
        }
        foreach(string line in split(data,"\n")){
            if(line.length == 0){
                continue;
            }
            string[] proc_args = argument_process(split(line," "));
            if(proc_args[0] != null){
                add_process(proc_args[0],proc_args[1:]);
            }
        }
    }
}
public string[] argument_process(string[] args){
     string[] new_args = {};
     foreach (string arg in args){
         if(arg.length > 1 && arg[0] == '$'){
             arg = get_value(arg[1:]);
         }
         if(arg[0] == '-'){
             continue;
         }
         new_args += arg;
     }
     return new_args;
}

public Inary inary_init(string[] args){
    wsl_block();
    Inary app = new Inary();
    parse_args(args);
    settings_init();
    set_env("G_DEBUG","fatal-criticals");
    error(31);
    return app;
}

public string get_alias_type(string type){
    switch(type){
        case "la":
            return "list-available";
        case "li":
            return "list-installed";
        case "it":
            return "install";
        default:
            return type;
    }
}


