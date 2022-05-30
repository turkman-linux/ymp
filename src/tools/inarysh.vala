public int main(string[] args){
    if (args[1] == "--help"){
        print_stderr("Usage: inarysh [file/-]");
        print_stderr("  file: inary script path");
        print_stderr("   -  : read from stdin");
        return 0;
    }
    Inary inary = inary_init(args);
    if(args[1] == "-" || args.length == 1){
        set_bool("shellmode",false);
        while(!stdin.eof()){
            string prompt = colorize("Inary >> ",blue);
            #if no_libreadline
                print_fn(prompt,false,false);
                inary.add_script(stdin.read_line());
            #else
               inary.add_script(Readline.readline(prompt));
            #endif
            inary.run();
            inary.clear_process();
        }
    }else{
        string data = readfile(args[1]);
        inary.add_script(data);
        inary.run();
        inary.clear_process();
    }
    return 0;
}
