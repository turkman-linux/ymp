public int main(string[] args){
    if (args[1] == "--help"){
        print_stderr("Usage: inarysh [file/-]");
        print_stderr("  file: inary script path");
        print_stderr("   -  : read from stdin");
        return 0;
    }
    Inary inary = inary_init(args);
    if(args[1] == "-" || args.length == 1){
        while(!stdin.eof()){
            inary.add_script(stdin.read_line());
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
