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
    operation op = new operation();
    op.help = new helpmsg();
    op.callback.connect(shitcat_main);
    op.names = {_("shit"),"shitcat","shit"};
    op.help.name = _("shitcat");
    op.help.minargs=1;
    op.help.shell_only = true;
    op.help.description = _("Write message with bad appearance.");
    op.help.add_parameter("!!!",_("FUCK LGBT"));
    op.help.add_parameter("-",_("read from stdin"));
    add_operation(op);
}
