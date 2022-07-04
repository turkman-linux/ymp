public int cowcat_main(string[] args){
    string data="";
    if(args[0] == "-" || args.length == 0){
        string line = " ";
        while(line != ""){
            line = stdin.read_line();
            data += line+"\n";
        }
    }else{
        data = readfile(args[0]);
    }
    print_with_cow(data);
    return 0;
}

void cowcat_init(){
    add_operation(cowcat_main,{"cow","moo","cowcat"});
}
