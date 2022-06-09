int main(string[] args){
    inary_init(args);
    if (args.length < 4){
        print_stderr("Usage: iniget [file] [section] [variable]");
        return 1;
    }
    string[] new_args = argument_process(args);
    var file = new_args[1];
    var section = new_args[2];
    var variable = new_args[3];
    var ini = new inifile();
    ini.load(file);
    var value = ini.get(section,variable);
    if (value != null){
        stdout.printf(value+"\n");
    }
    return 0;
}
