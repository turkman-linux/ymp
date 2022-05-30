public int get_main(string[] args){
    if(args.length < 1){
        foreach(string name in list_values()){
            print(name+":"+get_value(name));
        }
        return 0;
    }
    var value = get_value(args[0]);
    print(value);
    return 0;
}
public void get_help(){
    print_stderr("print a inary variable");
}
