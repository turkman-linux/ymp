public int shell_main(string[] args){
    Inary ymp = ymp_init(args);
    if(args[0] == "-" || args.length == 0){
        set_bool("shellmode",true);
        while(!stdin.eof()){
            string prompt = colorize("Inary >> ",blue);
            #if no_libreadline
                print_fn(prompt,false,false);
                string line = stdin.read_line();
            #else
                string line = Readline.readline(prompt);
            #endif
            if(line != null){
                ymp.add_script(line);
                ymp.run();
                ymp.clear_process();
            }else{
                print("\n"+"Use exit or Ctrl-C");
            }
        }
    }else{
        string data = readfile(args[0]);
        ymp.add_script(data);
        ymp.run();
        ymp.clear_process();
    }
    return 0;
}

void shell_init(){
    add_operation(shell_main,{"shell","sh"});
}
