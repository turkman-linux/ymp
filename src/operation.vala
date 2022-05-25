public int operations_main(string name,string[] args){
    switch(name){
        case "install":
            return install_main(args);
        default :
            log.error_add("Invalid operation");
            log.error(1);
            break;
    }
    return 0;
}
