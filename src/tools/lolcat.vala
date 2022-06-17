int main(string[] args){
    if(args[1] == "-"){
        string line = " ";
        while(line != ""){
            line = stdin.read_line();
            lolcat(line);
            print_fn("\n",false,false);
        }
        return 0;
    }
    string data = readfile(args[1]);
    lolcat(data);
    return 0;
}