public int dummy_operation(string[] args){
    return 0;
}
void dummy_init(){
    var h = new helpmsg();
    h.name = "init";
    h.description = "Do nothing.";
    add_operation(dummy_operation,{"init",":", "#"},h);
}
