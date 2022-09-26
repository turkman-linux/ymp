public int echo_main(string[] args){
    string data="";
    foreach(string arg in args){
        data += arg+" ";
    }
    print(data[0:data.length-1]);
    return 0;
}
void echo_init(){
    add_operation(echo_main,{"echo"},"Write message to terminal.");
}
