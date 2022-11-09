public int fetch_main(string[] args){
    ymp_init(args);
    if(args.length < 1){
        error_add("URL missing");
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
    h.name = "fetch";
    h.minargs=1;
    h.description = "Download files from network";
    add_operation(fetch_main,{"fetch","download","dl"}, h);
}
