void progressbar(double cur, double total, string filename){
    int percent = (int)(cur*100/total);
    if(percent < 0 || percent > 100){
        return;
    }
    print_fn("\x1b[2K\r%s%d\t%s\t%s\t%s".printf(
        "%",
        percent,
        sbasename(filename),
        GLib.format_size((uint64)cur),
        GLib.format_size((uint64)total)
    ),false,true);
}

int main (string[] args) {
    Ymp ymp = ymp_init(args);
    string[] new_args = argument_process(args);
    if(get_bool("sandbox")){
        var a = new array();
        a.adds(args);
        a.remove("--sandbox");;
        return run_sandbox_main(a.get());
    }
    if(get_bool("version")){
        write_version();
        return 0;
    }
    if(new_args.length < 2){
        error_add("No command given.\nRun "+ colorize("ymp help",red)+ " for more information about usage.");
        error(31);
    }else{
        ymp.add_process(new_args[1],new_args[2:]);
    }
    set_fetcher_progress(progressbar);
    ymp.run();
    error(1);
    return 0;
}
