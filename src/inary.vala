//DOC: ## class Inary
//DOC: libinary operation controller
//DOC: For example:
//DOC: ```vala
//DOC: int main(string[] args){
//DOC:     var inary = new inary_init(args);
//DOC:     inary.add_process("install",{"ncurses", "readline"});
//DOC:     inary.add_script("install bash glibc perl");
//DOC:     inary.run();
//DOC:     return 0;
//DOC: }
//DOC: ```

private delegate int function(string[] args);

private operation[] ops;
private class operation{
    public function callback;
    public string[] names;
}
private void add_operation(function callback, string[] names){
    if(ops == null){
        ops = {};
    }
    operation op = new operation();
    op.callback = callback;
    op.names = names;
    ops += op;
}

private int operation_main(string type, string[] args){
    debug("RUN:"+type + ":" + join(" ",args));
    foreach(operation op in ops){
        foreach(string name in op.names){
            if(type == name){
                return op.callback(args);
            }
        }
    }
    warning("Invalid operation name: "+type);
    return 0;
}

private class process{
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

    //DOC: `void Inary.add_process(string type, string[] args):`
    //DOC: add inary process using **type** and **args**
    //DOC: * type is operation type (install, remove, list-installed ...)
    //DOC: * args is operation argument (package list, repository list ...)
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
    //DOC: `void Inary.clear_process():`
    //DOC: remove all inary process
    public void clear_process(){
        proc = {};
    }

    //DOC: `void Inary.run():`
    //DOC: run inary process then if succes remove
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

    //DOC: `void Inary.add_script(string data):`
    //DOC: add inary process from inary script
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
//DOC: `string[] argument_process(string[] args):`
//DOC: Clear options and apply variables from argument
public string[] argument_process(string[] args){
     string[] new_args = {};
     bool e = false;
     foreach (string arg in args){
        if(arg == "--"){
            e = true;
            continue;
        }
        if(e){
            new_args += arg;
            continue;
        }
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

private void directories_init(){
    create_dir(get_build_dir());
    create_dir(get_storage()+"/index/");
    create_dir(get_storage()+"/packages/");
    create_dir(get_storage()+"/metadata/");
    create_dir(get_storage()+"/files/");
    create_dir(get_storage()+"/quarantine/");

}

private bool inary_activated = false;

//DOC: `Inary inary_init(string[] args):`
//DOC: start inary application.
//DOC: * args is program arguments
public Inary inary_init(string[] args){
    wsl_block();
    Inary app = new Inary();
    if(inary_activated){
        return app;
    }
    parse_args(args);
    ctx_init();
    settings_init();
    inrbuild_init();
    #if check_oem
        if(is_oem_available()){
            if(!get_bool("ALLOW-OEM")){
                warning("OEM detected! Inary may not working good.");
                error_add("OEM is not allowed! Please use --allow-oem to allow oem.");
            }
        }
    #endif
    set_env("G_DEBUG","fatal-criticals");
    error(31);
    inary_activated = true;
    tty_size_init();
    directories_init();
    return app;
}

