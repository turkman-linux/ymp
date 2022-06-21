public int upgrade_main(string[] args){
    string[] need_upgrade = {};
    foreach(string name in list_installed_packages()){
        package pi = get_installed_package(name);
        package pr = get_package_from_repository(name);
        if(pi.release < pr.release){
            need_upgrade += name;
        }
    }
    return install_main(need_upgrade);
}

public void upgrade_init(){
    add_operation(install_main,{"upgrade","ug"});
}
