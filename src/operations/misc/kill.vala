public int kill_main(string[] args){
    string self_hash = calculate_md5sum("/proc/self/exe");
    int self_pid = Posix.getpid();
    foreach(string dir in listdir("/proc")){
        if(int.parse(dir) != 0){
            int pid = int.parse(dir);
            if(pid != self_pid){
                if(issymlink("/proc/"+dir+"/exe")){
                    try{
                        GLib.FileUtils.read_link("/proc/"+dir+"/exe");
                    }catch(Error e){
                        continue;
                    }
                    string hash = calculate_md5sum("/proc/"+dir+"/exe");
                    if(hash == self_hash){
                        info("Kill: "+pid.to_string());
                        ckill(pid);
                    }
                }
            }
        }
    }
    print(self_hash);
    return 0;
}
void kill_init(){
    var h = new helpmsg();
    h.name = "kill";
    h.description = "Kill all other ymp process";
    add_operation(kill_main,{"kill","gg","ğ"},h);
}
