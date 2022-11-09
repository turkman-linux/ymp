public int update_main(string[] args){
    if(!is_root()){
        error_add("You must be root!");
        error(1);
    }
    single_instance();
    update_repo();
    return 0;
}

void update_init(){
    var h = new helpmsg();
    h.name = "update";
    h.description = "Update repo index cache.";
    add_operation(update_main,{"update","up"}, h);
}
