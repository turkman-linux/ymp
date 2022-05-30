public int set_main(string[] args){
    if(args.length < 2){
        return 1;
    }
    set_value(args[0],args[1]);
    return 0;
}
public void set_help(){
    print_stderr("Set a inary variable");
}
