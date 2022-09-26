int main (string[] args) {
    Ymp ymp = ymp_init(args);
    string[] new_args = argument_process(args);
    if(new_args.length < 2){
        error_add("No command given.\nRun "+ colorize("ymp-cli help",red)+ " for more information about usage.");
        error(31);
    }else{
        ymp.add_process(new_args[1],new_args[2:]);
    }
    ymp.run();
    error(1);
    return 0;
}
