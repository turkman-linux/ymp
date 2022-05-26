int main(string[] args){
    if (args.length < 4){
        print_stderr("Usage: iniget [file] [section] [variable]");
        return 1;
    }
    var file = args[1];
    var section = args[2];
    var variable = args[3];
    var ini = new inifile();
    ini.load(file);
    var value = ini.get(section,variable);
    if (value != null){
        stdout.printf(value+"\n");
    }
    return 0;
}
