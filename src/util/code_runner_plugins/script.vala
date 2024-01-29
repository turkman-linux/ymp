public void code_runner_script_init(){
    if(!isdir("/etc/code-runner/")){
        warning(_("%s directory does not exists.").printf("/etc/code-runner/"));
        return;
    }
    foreach(string plugin in listdir("/etc/code-runner/")){
        code_runner_plugin script = new code_runner_plugin();
        script.name = plugin;
        script.init.connect((image, directory)=>{
            backup_env();
            clear_env();
            set_env("IMAGE", image);
            set_env("DIRECTORY", directory);
            set_env("ACTION", "init");
            run("/etc/code-runner/%s".printf(plugin));
            restore_env();
            
        });
        script.run.connect((command)=>{
            backup_env();
            clear_env();
            set_env("COMMAND", command);
            set_env("ACTION", "run");
            int status = run("/etc/code-runner/%s".printf(plugin));
            restore_env();
            return status;
        });
        script.clean.connect(()=>{
            backup_env();
            clear_env();
            set_env("ACTION", "clean");
            run("/etc/code-runner/%s".printf(plugin));
            restore_env();
        });
        add_code_runner_plugin(script);
    }
}
