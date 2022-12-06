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
    var h = new helpmsg();
    h.name = _("cowcat");
    h.minargs=1;
    h.shell_only = true;
    h.description = _("Write a message with cow.");
    h.add_parameter("-",_("write from stdin"));
    add_operation(cowcat_main,{_("cow"),"cow","moo","cowcat"},h);
}
