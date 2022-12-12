public int extract_main(string[] args){
    var tar = new archive();
    tar.load(args[0]);
    if(get_bool("list")){
        foreach(string file in tar.list_files()){
            print(file);
        }
        return 0;
    }
    if(args.length > 1){
        foreach(string file in args[1:]){
            tar.extract(file);
        }
        return 0;
    }
    tar.extract_all();
    return 0;
}

void extract_init(){
    var h = new helpmsg();
    h.name = _("extract");
    h.minargs=1;
    h.description = _("Extract files from archive.");
    h.add_parameter("--list",_("List archive files"));
    add_operation(extract_main,{_("extract"),"extract","x"},h);
}
