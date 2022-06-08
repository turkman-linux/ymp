public int install_main(string[] args){
    string[] pkgs = resolve_dependencies(args);
    foreach(string pkg in args){
        print(pkg);
    }
    return 0;
}
public void install_init(){
    add_operation(install_main,{"install","it"});
}
