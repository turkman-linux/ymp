public int shitcat_main(string[] args){
    string data="";
    if(args[0] == "-"){
        string line = " ";
        while(line != ""){
            line = stdin.read_line();
            data += line+"\n";
            shitcat(data);
        }
    }else{
        data = readfile(args[0]);
        shitcat(data);
    }
    return 0;
}

void shitcat_init(){
    var h = new helpmsg();
    h.name = "shitcat";
    h.minargs=1;
    h.description = "Write message with bad appearance.";
    h.add_parameter("!!!","FUCK LGBT");
    h.add_parameter("-","read from stdin");
    add_operation(shitcat_main,{"shitcat","shit"},h);
}
