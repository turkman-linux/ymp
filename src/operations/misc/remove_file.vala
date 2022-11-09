public int remove_file_main(string[] args){
    foreach(string arg in args){
        remove_all(arg);
    }
    return 0;
}
void remove_file_init(){
    var h = new helpmsg();
    h.name = "remove-file";
    h.minargs=1;
    h.description = "Remove files or directories";
    add_operation(remove_file_main,{"rmf", "remove-file"},h);
}
