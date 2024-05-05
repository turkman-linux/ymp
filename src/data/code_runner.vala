private class code_runner_job {
    public string name;
    public string uses;
    public string image;
    public string directory;
    public string[] commands;
    public string[] environs;
}

public  class code_runner_plugin {
    public string name;
    public string ctx;
    public signal void init(string image, string directory);
    public signal int run(string command);
    public signal void clean();
}

private code_runner_plugin[] plugins;
public class code_runner {
    private yamlfile yaml;
    private array steps;
    private code_runner_job[] jobs;
    private string fail_job_name;
    public void load (string file){
        if (steps == null) {
            steps = new array();
        }
        if (jobs == null) {
            jobs = {};
        }
        yaml = new yamlfile();
        yaml.load (file);
        steps.adds(yaml.get_array (yaml.data, "steps"));
        fail_job_name = yaml.get_value(yaml.data, "on-fail");
        foreach (string import in yaml.get_array (yaml.data, "import")){
            load(import);
        }
        string jobs_area = yaml.get_area(yaml.data,"jobs");
        foreach (string area_name in yaml.get_area_names (jobs_area)){
            string area = yaml.get_area(jobs_area, area_name);
            var job = new code_runner_job ();
            job.name = area_name;
            job.uses = yaml.get_value(area,"uses");
            job.image = yaml.get_value(area,"image");
            job.directory = sdirname(file);
            job.environs = yaml.get_array(area,"environs");
            job.commands = yaml.get_array(area,"run");
            if (job.commands.length == 0) {
                job.commands = {yaml.get_value(area,"run")};
            }
            if(job.directory == ""){
                job.directory = pwd ();
            }
            jobs += job;
        }
    }
    public int run(){
        foreach (code_runner_job job in jobs){
            if(! (job.name in steps.get())){
                continue;
            }
            int status = run_job(job);
            if(status != 0){
                foreach (code_runner_job fjob in jobs){
                    if(fjob.name == fail_job_name){
                        run_job(fjob);
                    }
                }
                return status;
            }
        }
        return 0;
    }
    private int run_job(code_runner_job job){
        print(colorize("Run operation:",blue)+job.name);
        foreach(code_runner_plugin p in plugins) {
            if(p.name == job.uses){
                backup_env();
                clear_env();
                foreach(string env in job.environs){
                    string var = ssplit(env,"=")[0];
                    string val = env[var.length+1:];
                    set_env(var, val);
                }
                print(colorize("Init plugin:",green)+p.name);
                p.init(job.image, job.directory);
                print(colorize("Run plugin:",green)+p.name);
                foreach(string cmd in job.commands){
                    int status = p.run(cmd);
                    if(status != 0){
                        print_stderr(colorize("Failed:",red)+job.name);
                        print(colorize("Clean plugin:",green)+p.name);
                        p.clean();
                        return status;
                    }else{
                        print_stderr(colorize("Finish:",blue)+job.name);
                    }
                }
                print(colorize("Clean plugin:",green)+p.name);
                p.clean();
                restore_env();
            }
        }
        return 0;
    }
}
public void add_code_runner_plugin(code_runner_plugin plug){
    if(plugins == null){
        plugins = {};
    }
    info(_("Register code-runner plugin: %s").printf(plug.name));
    plugins += plug;
}

