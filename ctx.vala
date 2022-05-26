public string CONFIGDIR;
public string STORAGEDIR;
public void ctx_init(){
    CONFIGDIR="/etc";
    STORAGEDIR="/var/lib/inary";
}
public int operation_main(string name,string[] args){
    switch(name){
        case "exec":
            return exec_main(args);
        case "install":
            return install_main(args);
        case "echo":
            return echo_main(args);
        default :
            error_add("Invalid operation");
            error(1);
            break;
    }
    return 0;
}
public void help(){
    exec_help();
    install_help();
    echo_help();
}
