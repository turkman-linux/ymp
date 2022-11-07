public int index_operation(string[] args){
    foreach(string arg in args){
        string path = srealpath(arg);
        string index = create_index_data(path);
        writefile(path+"/ymp-index.yaml",index);
    }
    return 0;
}
void index_init(){
    var h = new helpmsg();
    h.name = "index";
    h.minargs=1;
    h.description = "Create repository index.";
    add_operation(index_operation,{"index", "ix"},h);
}
