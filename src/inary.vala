public delegate int function(string[] args);

private operation[] ops;
public class operation{
    public function callback;
    public string[] names;
}
public void add_operation(function callback, string[] names){
    if(ops == null){
        ops = {};
    }
    operation op = new operation();
    op.callback = callback;
    op.names = names;
    ops += op;
}

public int operation_main(string type, string[] args){
    print(type + ":" + join(" ",args));
    foreach(operation op in ops){
        foreach(string name in op.names){
            if(type == name){
                return op.callback(args);
            }
        }
    }
    return 0;
}

public class process{
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
    process[] proc;
    
    public void add_process(string type, string[] args){
        if(proc == null){
            proc = {};
        }
        if(type == null){
           return;
        }
        process op = new process();
        op.type = type;
        op.args = args;
        proc += op;
    }
    public void clear_process(){
        proc = {};
    }
    public void run(){
        for(int i=0;i<proc.length;i++){
            int status = proc[i].run();
            if(status != 0){
                string type = proc[i].type;
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
        foreach(string line in ssplit(data,"\n")){
            if(line.length == 0){
                continue;
            }
            string[] proc_args = argument_process(ssplit(line," "));
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

private bool inary_activated = false;
public Inary inary_init(string[] args){
    wsl_block();
    Inary app = new Inary();
    if(inary_activated){
        return app;
    }
    parse_args(args);
    ctx_init();
    settings_init();
    set_env("G_DEBUG","fatal-criticals");
    error(31);
    inary_activated = true;
    return app;
}


