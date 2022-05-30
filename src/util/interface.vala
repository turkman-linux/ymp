public bool yesno(string message){
    if(!config.interactive){
        return true;
    }
    #if no_libareadline
       print_fn(message+" [y/n]",false,true);
       var response = stdin.read_line();
    #else
       var response = Readline.readline(message+" [y/n]");       
    #endif
    return (response[0] == 'y' || response[0] == 'Y');
}
