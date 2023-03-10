public int brainfuck_main(string[] args){
    brainfuck(readfile_raw(args[0]),1024*1024);
    return 0;
}

void brainfuck_init(){
    var h = new helpmsg();
    h.name = _("brainfuck");
    h.minargs=1;
    h.description = _("Run a brainfuck script.");
    add_operation(brainfuck_main,{_("brainfuck"),"brainfuck","bf"},h);
}
