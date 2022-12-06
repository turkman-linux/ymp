public int dummy_operation(string[] args){
    return 0;
}
void dummy_init(){
    var h = new helpmsg();
    h.name = _("init");
    h.shell_only = true;
    h.description = _("Do nothing.");
    add_operation(dummy_operation,{_("init"),"init",":", "#"},h);
}
