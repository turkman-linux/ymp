public int echo_main(string[] args){
    string data="";
    foreach(string arg in args){
        data += arg+" ";
    }
    print(data[0:data.length-1]);
    return 0;
}
void echo_init(){
    var h = new helpmsg();
    h.name = "echo";
    h.description = "Write a message to terminal.";
    add_operation(echo_main,{"echo"},h);
}
