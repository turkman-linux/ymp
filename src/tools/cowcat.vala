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
    print_with_cow(data);
    return 0;
}
