public int help_main(string[] args){
    if (args.length == 0){
        foreach(operation op in ops){
            write_op_help(op);
            print_fn("\n",false,false);
        }
    }else{
        foreach(string arg in args){
            foreach(operation op in ops){
                if(arg in op.names){
                    write_op_help(op);
                }
            }
        }
    
    }
    return 0;
}

private void write_op_help(operation op){
    print(colorize("Operation ",blue)+join("/",op.names)+":");
    print(op.help);
}
void help_init(){
    add_operation(help_main,{"help"},"write help messages.");
}
