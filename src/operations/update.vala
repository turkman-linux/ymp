public int update_main(string[] args){
    update_repo();
    return 0;
}

public void update_init(){
    add_operation(update_main,{"update","up"});
}
