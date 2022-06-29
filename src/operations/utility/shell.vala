public int shell_main(string[] args){
    Inary inary = inary_init(args);
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
                inary.add_script(line);
                inary.run();
                inary.clear_process();
            }else{
                print("\n"+"Use exit or Ctrl-C");
            }
        }
    }else{
        string data = readfile(args[0]);
        inary.add_script(data);
        inary.run();
        inary.clear_process();
    }
    return 0;
}

void shell_init(){
    add_operation(shell_main,{"shell","sh"});
}
