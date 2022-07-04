public int shitcat_main(string[] args){
    string data="";
    if(args[0] == "-"){
        string line = " ";
        while(line != ""){
            line = stdin.read_line();
            data += line+"\n";
        }
    }else{
        data = readfile(args[0]);
    }
    shitcat(data);
    return 0;
}

void shitcat_init(){
    add_operation(shitcat_main,{"shitcat","shit"});
}
