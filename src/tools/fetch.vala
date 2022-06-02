int main(string[] args){
    inary_init(args);
    if(args.length < 2){
        error_add("URL missing");
        error(2);
    }
    set_fetcher_progress(progressbar);
    if(args.length > 2){
        fetch(args[1],args[2]);
    }else{
        stdout.printf(fetch_string(args[1]));
    }
    return 0;
}

public void progressbar(double cur, double total, string filename){
    int percent = (int)(cur*100/total);
    print_fn("\x1b[2K\r"+filename + " "+percent.to_string(),false,true);
}
