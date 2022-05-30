public int list_installed_main(string[] args){
    foreach(string pkg in list_installed_packages()){
        print(pkg);
    }
    return 0;
}

public void list_installed_help(){
    print("list installed packages");
}
