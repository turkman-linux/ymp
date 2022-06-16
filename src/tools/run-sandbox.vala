int main(string[] args){
    sandbox_network = true;
    clear_env();
    set_env("PATH","/bin:/usr/bin:/sbin:/usr/sbin");
    int status = sandbox(args[1:]);
    return status/256;
}
