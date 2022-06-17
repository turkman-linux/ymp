int main(string[] args){
    string data="";
    if(args[1] == "-"){
        string line = " ";
        while(line != ""){
            line = stdin.read_line();
            data += line+"\n";
        }
    }else{
        data = readfile(args[1]);
    }
    shitcat(data);
    return 0;
}
