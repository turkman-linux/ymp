public int echo_main(string[] args){
    string data="";
    foreach(string arg in args){
        data += arg+" ";
    }
    print(data[0:data.length-1]);
    return 0;
}
public void echo_help(){
    print_stderr("write string to console");
}
