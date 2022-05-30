public int list_available_main(string[] args){
    foreach(repository repo in get_repos()){
        foreach(string name in repo.list_packages()){
            var description = repo.get_package(name).get("description");
            print(name + " " + description);
        }
    }
    return 0;
}

public void list_available_help(){
    print("list available packages");
}
