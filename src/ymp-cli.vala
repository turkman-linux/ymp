private string old_line;
void progressbar(double cur, double total, string filename){
    int percent = (int)(cur*100/total);
    if(percent < 0 || percent > 100){
        return;
    }
    string del="";
    if(!get_bool("no-color")){
        del = "\x1b[A\x1b[2K\r";
    }
    string line = del+"%s%d  %s  %s  %s".printf(
        "%",
        percent,
        sbasename(filename),
        GLib.format_size((uint64)cur),
        GLib.format_size((uint64)total));
    if(line != old_line){
        print_stderr(line);
        old_line = line;
    }
}

int main (string[] args) {
    Ymp ymp = ymp_init(args);
    if(get_bool("sandbox")){
        var a = new array();
        a.adds(args);
        a.remove("--sandbox");
        return run_sandbox_main(a.get());
    }
    if(get_bool("version")){
        write_version();
        return 0;
    }
    string[] new_args = argument_process(args);
    if(new_args.length < 2){
        error_add("No command given.\nRun "+ colorize("ymp help",red)+ " for more information about usage.");
        error(31);
    }else{
        ymp.add_process(new_args[1],new_args[2:]);
    }
    set_fetcher_progress(progressbar);
    ymp.run();
    error(1);
    return 31;
}
