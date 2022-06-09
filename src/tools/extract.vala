int main(string[] args){
    inary_init(args);
    if(args.length < 2){
        error_add("Archive Missing");
        error(2);
    }
    var tar = new archive();
    string[] new_args = argument_process(args);
    tar.load(new_args[1]);
    tar.extract_all();
    return 0;
}
