public int brainfuck_main (string[] args) {
    brainfuck (readfile_raw (args[0]), 1024 * 1024);
    return 0;
}

void brainfuck_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (brainfuck_main);
    op.names = {_ ("brainfuck"), "brainfuck", "bf"};
    op.help.name = _ ("brainfuck");
    op.help.minargs = 1;
    op.help.description = _ ("Run a brainfuck script.");
    add_operation (op);
}
