public int list_installed_main(string[] args){
    foreach(string pkg in list_installed_packages()){
        var p = get_installed_packege(pkg);
        print(pkg+"\t"+p.get("description"));
    }
    return 0;
}

public void list_installed_help(){
    print("list installed packages");
}
