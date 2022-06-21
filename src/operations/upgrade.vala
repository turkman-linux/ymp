public int upgrade_main(string[] args){
    string[] need_upgrade = {};
    foreach(string name in list_installed_packages()){
        if(!is_available_package(name)){
            continue;
        }
        package pi = get_installed_package(name);
        package pr = get_package_from_repository(name);
        if(pi.release < pr.release){
            need_upgrade += name;
        }
    }
    return install_main(need_upgrade);
}

public void upgrade_init(){
    add_operation(upgrade_main,{"upgrade","ug"});
}
