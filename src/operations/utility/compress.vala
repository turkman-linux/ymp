public int compress_main(string[] args){
    var tar = new archive();
    tar.load(args[0]);
    set_archive_type(get_value("type"), get_value("algorithm"));
    if(args.length > 1){
        foreach(string file in args[1:]){
            if(isdir(file)){
                foreach(string path in find(file)){
                    tar.add(path);
                }
            }else{
                tar.add(file);
            }
        }
    }
    tar.create();
    return 0;
}

void compress_init(){
    var h = new helpmsg();
    h.name = _("compress");
    h.minargs=1;
    h.description = _("Compress file or directories.");
    h.add_parameter("--algorithm",_("compress algorithm"));
    h.add_parameter("--type",_("archive format"));
    add_operation(compress_main,{_("compress"),"compress","prs"},h);
}
