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
            setenv("IMAGE", image, 1);
            setenv("DIRECTORY", directory, 1);
            setenv("ACTION", "init", 1);
            run("%s/%s".printf(plugin_directory ,plugin));

        });
        script.run.connect((command)=>{
            setenv("COMMAND", command, 1);
            setenv("ACTION", "run", 1);
            int status = run("%s/%s".printf(plugin_directory, plugin));
            return status;
        });
        script.clean.connect(()=>{
            setenv("ACTION", "clean", 1);
            run("%s/%s".printf(plugin_directory, plugin));
        });
        add_code_runner_plugin(script);
    }
    code_runner_plugin_init_done = true;
}
