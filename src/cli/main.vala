int main (string[] args) {
    /*
    ██████╗  ██╗
    ╚════██╗███║
     █████╔╝╚██║
     ╚═══██╗ ██║
    ██████╔╝ ██║
    ╚═════╝  ╚═╝
    */
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
    if(args.length < 2){
        error_add(_("No command given.")+"\n"+_("Run %s for more information about usage.").printf(colorize(_("ymp help"),red)));
        error(31);
    }else{
        ymp.add_process(args[1],args[2:]);
    }
    ymp.run();
    error(1);
    return 0;
}
