//DOC: ## class Ymp
//DOC: libymp operation controller
//DOC: For example:
//DOC: ```vala
//DOC: int main(string[] args){
//DOC:     var ymp = new ymp_init(args);
//DOC:     ymp.add_process("install",{"ncurses", "readline"});
//DOC:     ymp.add_script("install bash glibc perl");
//DOC:     ymp.run();
//DOC:     return 0;
//DOC: }
//DOC: ```

#if no_locale
public string _(string msg){
    return msg;
}
#else
public const string GETTEXT_PACKAGE="ymp";
#endif
private delegate int function(string[] args);

private operation[] ops;
private class operation{
    public function callback;
    public string[] names;
    public helpmsg help;
}

private void add_operation(function callback, string[] names, helpmsg help){
    logger_init(); // logger reload
    if(ops == null){
        ops = {};
    }
    operation op = new operation();
    op.callback = (function) callback;
    op.names = names;
    op.help = help;
    ops += op;
}

private void lock_operation(){
    block_sigint();
    if(get_bool("unblock")){
        unblock_sigint();
    }
}
private void unlock_operation(){
    unblock_sigint();
}

private int operation_main(string type, string[] args){
    info(_("RUN:")+type + ":" + join(" ",args));
    foreach(operation op in ops){
        foreach(string name in op.names){
            if(type == name){
                if(get_bool("help") || op.help.minargs > args.length){
                    return help_main({name});
                }        
                set_value_readonly("operation",name);
                parse_args(args);
                return op.callback(argument_process(args));
            }
        }
    }
    warning(_("Invalid operation name: %s").printf(type));
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

private class script_label{
    public string name;
    public int line;
}
public class Ymp {
    process[] proc;
    private int iflevel = 0;

    //DOC: `void Ymp.add_process(string type, string[] args):`
    //DOC: add ymp process using **type** and **args**
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
    //DOC: `void Ymp.clear_process():`
    //DOC: remove all ymp process
    public void clear_process(){
        proc = {};
    }

    //DOC: `void Ymp.run():`
    //DOC: run ymp process then if succes remove
    public void run(){
        script_label[] labels = {};
        for(int i=0;i<proc.length;i++){
            long start_time = get_epoch();
            if (proc[i].type == "label"){
                script_label l = new script_label();
                l.name = proc[i].args[0];
                l.line = i;
                if(!(l in labels)){
                    labels += l;
                }
            }

            if (proc[i].type == "if"){
                process op = new process();
                op.type = proc[i].args[0].strip();
                op.args = proc[i].args[1:];
                if(iflevel == 0){
                    lock_operation();
                    int status = op.run();
                    unlock_operation();
                    if (status != 0){
                        iflevel += 1;
                    }
                }else{
                    iflevel += 1;
                }
                continue;
            }else if (proc[i].type == "endif"){
                iflevel -= 1;
                continue;
            }
            if(iflevel < 0){
                error_add(_("Syntax error. Unexceped endif detected."));
            }else if(iflevel != 0){
                continue;
            }
            if (proc[i].type == "goto"){
                string name = proc[i].args[0];
                foreach(script_label l in labels){
                    if(l.name  == name){
                        i = l.line;
                        iflevel = 0;
                        break;
                    }
                }
                continue;
            }
            lock_operation();
            int status = proc[i].run();
            unlock_operation();
            if(status != 0){
                string type = proc[i].type;
                error_add(_("Process: %s failed. Exited with %d.").printf(type, status));
                set_terminal_title("");
                error(status);
            }
            float diff = ((float)(get_epoch() - start_time))/ 1000000;
            info(_("Process done in : %f sec").printf(diff));
            set_terminal_title("");
        }
        error(1);
    }

    //DOC: `void Ymp.add_script(string data):`
    //DOC: add ymp process from ymp script
    public void add_script(string data){
        if(data == null){
            return;
        }
        foreach(string line in ssplit(data,"\n")){
            line = line.strip();
            line = ssplit(line,"#")[0];
            if(line.length == 0){
                continue;
            }
            string[] proc_args = ssplit(line," ");
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
         if(!e && startswith(arg,"--")){
             continue;
         }
         new_args += arg;
     }
     return new_args;
}

private void directories_init(){
    create_dir(get_build_dir());
    GLib.FileUtils.chmod(get_build_dir(),0777);
    create_dir(get_storage()+"/index/");
    create_dir(get_storage()+"/packages/");
    create_dir(get_storage()+"/metadata/");
    create_dir(get_storage()+"/files/");
    create_dir(get_storage()+"/links/");
    create_dir(get_storage()+"/sources.list.d/");
    create_dir(get_storage()+"/quarantine/");
    if(!isexists(get_storage()+"/sources.list")){
        writefile(get_storage()+"/sources.list","");
    }
    foreach(string path in find(get_storage())){
        GLib.FileUtils.chmod(path,0755);
        if(is_root()){
            Posix.chown(path,0,0);
        }
    }
}

private bool ymp_activated = false;

//DOC: `Ymp ymp_init(string[] args):`
//DOC: start ymp application.
//DOC: * args is program arguments
public Ymp ymp_init(string[] args){
    #if no_locale
    #else
    GLib.Intl.setlocale (LocaleCategory.ALL, "");
    GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, "/usr/share/locale");
    GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
    GLib.Intl.textdomain (GETTEXT_PACKAGE);
    #endif
    Posix.umask(022);
    logger_init();
    wsl_block();
    Ymp app = new Ymp();
    if(ymp_activated){
        return app;
    }
    settings_init();
    parse_args(args);
    ctx_init();
    directories_init();
    #if check_oem
        if(is_oem_available()){
            if(!get_bool("ALLOW-OEM")){
                warning(_("OEM detected! Ymp may not working good."));
                error_add(_("OEM is not allowed! Please use --allow-oem to allow oem."));
            }
        }
    if(usr_is_merged()){
        warning(_("UsrMerge detected! Ymp may not working good."));
    }
    #endif
    //set_env("G_DEBUG","fatal-criticals");
    if(has_error()){
        error(31);
    }
    
    ymp_activated = true;
    tty_size_init();
    logger_init(); // logger reload
    if(get_bool("daemon")){
        skeleton_daemon();
    }
    return app;
}

