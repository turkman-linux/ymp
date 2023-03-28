public int cowcat_main(string[] args){
    string data="";
    if(args[0] == "-" || args.length == 0){
        string line = " ";
        while(line != ""){
            line = stdin.read_line();
            data += line+"\n";
            print_with_cow(data);
        }
    }else{
        data = readfile(args[0]);
        print_with_cow(data);
    }
    return 0;
}

void cowcat_init(){
    operation op = new operation();
    op.help = new helpmsg();
    op.callback.connect(cowcat_main);
    op.names = {_("cow"),"cow","moo","cowcat"};
    op.help.name = _("cowcat");
    op.help.minargs=1;
    op.help.shell_only = true;
    op.help.description = _("Write a message with cow.");
    op.help.add_parameter("-",_("write from stdin"));
    add_operation(op);
}
