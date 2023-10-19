private class code_runner_job {
    public string name;
    public string uses;
    public string image;
    public string directory;
    public string[] commands;
}

private  class code_runner_plugin {
    public string name;
    public string ctx;
    public signal void init(string image, string directory);
    public signal int run(string command);
    public signal void clean();
}

public class code_runner {
    private yamlfile yaml;
    private array steps;
    private code_runner_plugin[] plugins;
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
            job.directory = yaml.get_value(area,"directory");
            job.commands = yaml.get_array(area,"run");
            if (job.commands.length == 0) {
                job.commands = {yaml.get_value(area,"run")};
            }
            if(job.directory == ""){
                job.directory = pwd ();
            }
            jobs += job;
        }
        plugins = get_code_runner_plugins();
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
            }
        }
        return 0;
    }
}

private code_runner_plugin[] get_code_runner_plugins(){
    code_runner_plugin[] ret = {};
    // docker plugin
    var docker = new code_runner_plugin();
    docker.name = "docker";
    docker.init.connect((image, directory)=>{
        run_args({"docker", "pull", image});
        docker.ctx = getoutput("docker run -it -d -v '%s':/root '%s' 2>/dev/null".printf(directory.replace("'","\\'"), image.replace("'",""))).strip();
    });
    docker.run.connect((command)=>{
        return run_args({"docker", "exec", docker.ctx, "sh", "-c", command});
    });
    docker.clean.connect(()=>{
        run_args({"docker", "rm", "-f", docker.ctx});
    });
    ret += docker;
    // local plugin
    var local = new code_runner_plugin();
    local.name = "local";
    local.init.connect((image, directory)=>{
        local.ctx = directory;
        return;
    });
    local.run.connect((command)=>{
        string cur = pwd ();
        cd(local.ctx);
        int status = run_args({"sh", "-c", command});
        cd (cur);
        return status;
    });
    local.clean.connect(()=>{
        return;
    });
    ret += local;
    return ret;
}
