public int compress_main(string[] args){
    var tar = new archive();
    tar.load(args[0]);
    if(get_value("compress")=="none"){
        afilter=0;
    }else if(get_value("compress")=="gzip"){
        afilter=1;
    }else if(get_value("compress")=="xz"){
        afilter=2;
    }
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
    h.add_parameter("--compress",_("Compress format"));
    add_operation(compress_main,{_("compress"),"compress","prs"},h);
}
