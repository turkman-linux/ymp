public int install_main(string[] args){
    print(args[0]);
    return 0;
}
public void install_init(){
    add_operation(install_main,{"install","it"});
}
