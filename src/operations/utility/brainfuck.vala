private static int brainfuck_main (string[] args) {
    if(get_bool("compile")){
        bf_compile(readfile_raw (args[0]));
        //print(ccode);
        if(isfile("/tmp/bf.elf")){
            move_file("/tmp/bf.elf",pwd()+"/main");
            return 0;
        }
        return 1;
    }
    brainfuck (readfile_raw (args[0]), 1024 * 1024);
    return 0;
}

static void brainfuck_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (brainfuck_main);
    op.names = {_ ("brainfuck"), "brainfuck", "bf"};
    op.help.name = _ ("brainfuck");
    op.help.minargs = 1;
    op.help.description = _ ("Run a brainfuck script.");
    add_operation (op);
}
