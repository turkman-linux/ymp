public int main(string[] args){
    if (args.length < 2){
        print_stderr("Usage: inarysh [file]");
    }
    Inary inary = inary_init();
    
    string data = readfile(args[1]);
    inary.add_script(data);
    inary.run();
    return 0;
}
