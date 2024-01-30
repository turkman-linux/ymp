code_runner_plugin docker;
private static void docker_init(string image, string directory){
        run_args({"docker", "pull", image});
        docker.ctx = getoutput(
                "docker run -it --env-file=<(cat /proc/self/environ | tr '\\0' '\\n') -d "
                + "-v '%s':/root '%s' 2>/dev/null".printf(
                directory.replace("'","\\'"), image.replace("'",""))
        ).strip();
}

private static int docker_run(string command){
        return run_args({"docker", "exec", docker.ctx, "sh", "-c", command});
}
private static void docker_clean(){
        run_args({"docker", "rm", "-f", docker.ctx});
}

public void code_runner_docker_init(){
    docker = new code_runner_plugin();
    docker.name = "docker";
    docker.init.connect(docker_init);
    docker.run.connect(docker_run);
    docker.clean.connect(docker_clean);
    add_code_runner_plugin(docker);
}
