public int fetch_main(string[] args){
    ymp_init(args);
    if(args.length < 1){
        error_add("URL missing");
        error(2);
    }
    set_fetcher_progress(progressbar);
    if(args.length > 1){
        fetch(args[0],args[1]);
    }else{
        stdout.printf(fetch_string(args[0]));
    }
    return 0;
}

void progressbar(double cur, double total, string filename){
    int percent = (int)(cur*100/total);
    print_fn("\x1b[2K\r %"+percent.to_string()+"\t"+filename+"\t"+GLib.format_size((uint64)cur)+"\t"+GLib.format_size((uint64)total),false,true);
}

void fetch_init(){
    add_operation(fetch_main,{"fetch","download","dl"}, "Download file.");
}
