public string CONFIGDIR;
public string STORAGEDIR;
public string[] operation_names;
public void ctx_init(){
    CONFIGDIR = "/etc";
    STORAGEDIR = "/var/lib/inary";
    operation_names = {"exec", "help", "install", "echo", };
}
public int operation_main(string name,string[] args){
    switch(name){
        case "exec":
            return exec_main(args);
        case "help":
            return help_main(args);
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
public int operation_help(string name){
    print_stderr(colorize(name,blue)+":");
    switch(name){
        case "exec":
            exec_help();
            break;
        case "help":
            help_help();
            break;
        case "install":
            install_help();
            break;
        case "echo":
            echo_help();
            break;
        default :
            error_add("Invalid operation");
            error(1);
            break;
    }
    return 0;
}
