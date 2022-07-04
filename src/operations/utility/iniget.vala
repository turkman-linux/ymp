public int iniget_main(string[] args){
    if (args.length < 3){
        print_stderr("Usage: iniget [file] [section] [variable]");
        return 1;
    }
    string[] new_args = argument_process(args);
    var file = new_args[0];
    var section = new_args[1];
    var variable = new_args[2];
    var ini = new inifile();
    ini.load(file);
    var value = ini.get(section,variable);
    if (value != null){
        stdout.printf(value+"\n");
    }
    return 0;
}
void iniget_init(){
    add_operation(iniget_main,{"iniget","ini"});
}
