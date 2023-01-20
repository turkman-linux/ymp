public int fetch_main(string[] args){
    if(args.length < 1){
        error_add(_("URL missing"));
        error(2);
    }
    
    if(args.length > 1){
        fetch(args[0],args[1]);
    }else{
        string data = fetch_string(args[0]);
        if(data!=null || data != ""){
            stdout.printf(data);
        }
    }
    return 0;
}



void fetch_init(){
    var h = new helpmsg();
    h.name = _("fetch");
    h.minargs=1;
    h.description = _("Download files from network");
    h.add_parameter("--ignore-ssl",_("Disable ssl check"));
    add_operation(fetch_main,{_("fetch"),"fetch","download","dl"}, h);
}
