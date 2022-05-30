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
        return operation_main(type,args);
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
        string[] new_args = {};
        foreach (string arg in args){
            if(arg.length > 1 && arg[0] == '$'){
                arg = get_value(arg[1:]);
            }
            new_args += arg;
        }
        operation op = new operation();
        op.type = type;
        op.args = new_args;
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
            string[] proc_args = split(line," ");
            if(proc_args[0] != null){
                add_process(proc_args[0],proc_args[1:]);
            }
        }
    }
}
public Inary inary_init(string[] args){
    Inary app = new Inary();
    settings_init();
    parse_args(args);
    set_env("G_DEBUG","fatal-criticals");
    error(31);
    return app;
}
