public int debian_main(string[] args){
    string output = get_value("output");
    if(output == ""){
        output=pwd();
    }
    if(get_bool("extract")){
        foreach(string arg in args){
            deb_extract(arg,output);
        }
    }else if(get_bool("create")){
        foreach(string arg in args){
            deb_create(arg,output);
        }
    }
    return 0;
}

void debian_init(){
    var h = new helpmsg();
    h.name = _("debian");
    h.description = _("Debian package operations");
    add_operation(debian_main, {_("debian"),"deb","debian"},h);
}
