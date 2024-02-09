private static bool code_runner_plugin_init_done = false;
private static void code_runner_plugin_init(){
    if(code_runner_plugin_init_done){
        return;
    }
    string plugin_directory = get_value("plugindir");
    if(plugin_directory == ""){
        plugin_directory = "/lib/code-runner/";
    }
    if(!isdir(plugin_directory)){
        warning(_("%s directory does not exists.").printf(plugin_directory));
        return;
    }
    foreach(string plugin in listdir(plugin_directory)){
        code_runner_plugin script = new code_runner_plugin();
        script.name = plugin;
        script.init.connect((image, directory)=>{
            backup_env();
            clear_env();
            set_env("IMAGE", image);
            set_env("DIRECTORY", directory);
            set_env("ACTION", "init");
            run("%s/%s".printf(plugin_directory ,plugin));
            restore_env();
            
        });
        script.run.connect((command)=>{
            backup_env();
            clear_env();
            set_env("COMMAND", command);
            set_env("ACTION", "run");
            int status = run("%s/%s".printf(plugin_directory, plugin));
            restore_env();
            return status;
        });
        script.clean.connect(()=>{
            backup_env();
            clear_env();
            set_env("ACTION", "clean");
            run("%s/%s".printf(plugin_directory, plugin));
            restore_env();
        });
        add_code_runner_plugin(script);
    }
    code_runner_plugin_init_done = true;
}
