public int iniget_main(string[] args){
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
    var h = new helpmsg();
    h.name = "iniget";
    h.usage = "iniget [file] [section] [variable]";
    h.minargs = 3;
    h.description = "Parse ini files";
    add_operation(iniget_main,{"iniget","ini"}, h);
}
