int main(string[] args){
    inary_init(args);
    if(args.length < 2){
        error_add("Archive Missing");
        error(2);
    }
    var tar = new archive();
    tar.load(args[1]);
    tar.extract_all();
    return 0;
}
