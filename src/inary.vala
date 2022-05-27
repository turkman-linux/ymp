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
public inaryconfig config;

public class Inary {
    operation[] process;
    
    public void add_process(string type, string[] args){
        if(type == null){
            type = "";
        }    
        if(process == null){
            process = {};
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
        foreach(string line in data.split("\n")){
            string[] proc_args = line.split(" ");
            if(proc_args[0] != null){
                add_process(proc_args[0],proc_args[1:]);
            }
        }
    }
}
public Inary inary_init(){
    ctx_init();
    Inary app = new Inary();
    config = settings_init();
    enable_debug = (config.debug == "true");
    error(31);
    return app;
}
