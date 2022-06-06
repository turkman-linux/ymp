//DOC: ## WSL shit bloker
//DOC: detect & block WSL

//DOC: `void wsl_block():`
//DOC: If runs on WSL shit write fail message and exit :)
public void wsl_block(){
    var cmdline = readfile("/proc/version").down();
    if("microsoft" in cmdline){
        fuck();
    }else if ("wsl" in cmdline){
        fuck();
    }
    foreach(string line in readfile("/proc/cpuinfo").down().split("\n")){
        if("microcode" in line && "0xffffffff" in line){
            fuck();
        }
    }
    error(31);
}
private void fuck(){
    Posix.fork();
    print("Using inary in Fucking WSL environment is not allowed.");
    fuck();
}
