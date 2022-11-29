public int title_main(string[] args){
    string data="";
    foreach(string arg in args){
        data += arg+" ";
    }
    set_terminal_title(data[0:data.length-1]);
    return 0;
}
void title_init(){
    var h = new helpmsg();
    h.name = "title";
    h.minargs=1;
    h.shell_only = true;
    h.description = "Set terminal title";
    add_operation(title_main,{"title"},h);
}
