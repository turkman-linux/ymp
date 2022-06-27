public int inarysh_main(string[] args){
    if (args[1] == "--help"){
        print_stderr("Usage: inarysh [file/-]");
        print_stderr("  file: inary script path");
        print_stderr("   -  : read from stdin");
        return 0;
    }
    var inary = inary_init(args);
    if(args[1] == "-" || args.length == 1){
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
        string data = readfile(args[1]);
        inary.add_script(data);
        inary.run();
        inary.clear_process();
    }
    return 0;
}

void inarysh_init(){
    add_operation(inarysh_main,{"shell","sh"});
}
