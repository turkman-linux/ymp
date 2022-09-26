public int update_main(string[] args){
    update_repo();
    return 0;
}

void update_init(){
    add_operation(update_main,{"update","up"}, "Update repo index cache.");
}
