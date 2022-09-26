public int extract_main(string[] args){
    ymp_init(args);
    if(args.length < 1){
        error_add("Archive Missing");
        error(2);
    }
    var tar = new archive();
    string[] new_args = argument_process(args);
    tar.load(new_args[0]);
    if(get_bool("list")){
        foreach(string file in tar.list_files()){
            print(file);
        }
        return 0;
    }
    if(new_args.length > 1){
        foreach(string file in new_args[1:]){
            tar.extract(file);
        }
        return 0;
    }
    tar.extract_all();
    return 0;
}

void extract_init(){
    add_operation(extract_main,{"extract","x"},"Extract archive file.");
}
