int main(string[] args){
    inary_init(args);
    if(args.length < 2){
        error_add("URL missing");
        error(2);
    }
    if(args.length > 2){
        fetch(args[1],args[2]);
    }else{
        stdout.printf(fetch_string(args[1]));
    }
    return 0;
}
