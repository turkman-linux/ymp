public int brainfuck_main (string[] args) {
    if(get_bool("compile")){
        string ctx = readfile_raw (args[0]);
        string ccode = "#include <stdio.h>\n";
        ccode += "#include <stdlib.h>\n";
        ccode += "unsigned char cell[1024*1024];\n";
        ccode += "int ptr;\n";
        ccode += "void main(){\n";
        int i=0;
        while(i < ctx.length){
            char c = ctx[i];
            i++;
            if(c == '>'){
                ccode += "ptr++;\n";
            }else if (c == '<'){
                ccode += "ptr--;\n";
            }else if (c == '+'){
                ccode += "cell[ptr]++;\n";
            }else if (c == '-'){
                ccode += "cell[ptr]--;\n";
            }else if (c == '['){
                ccode += "while(cell[ptr]){\n";
            }else if (c == ']'){
                ccode += "}\n";
            }else if (c == '.'){
                ccode += "putc(cell[ptr],stdout);\n";
            }else if (c == '}'){
                ccode += "cell[ptr] = getchar();\n";
            }
        }
        ccode += "}";
        bf_compile(ccode);
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
