public int shitcat_main(string[] args){
    string data="";
    if(args[0] == "-"){
        string line = " ";
        while(line != ""){
            line = stdin.read_line();
            data += line+"\n";
        }
        shitcat(data);
    }else{
        data = readfile(args[0]);
        shitcat(data);
    }
    return 0;
}

void shitcat_init(){
    var h = new helpmsg();
    h.name = _("shitcat");
    h.minargs=1;
    h.shell_only = true;
    h.description = _("Write message with bad appearance.");
    h.add_parameter("!!!",_("FUCK LGBT"));
    h.add_parameter("-",_("read from stdin"));
    add_operation(shitcat_main,{_("shit"),"shitcat","shit"},h);
}
