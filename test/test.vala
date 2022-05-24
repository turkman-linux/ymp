void main(){
    // init inary
    Inary inary = inary_init();
    // archive test
    var tar = new archive();
    tar.load("../test/example/main.tar.gz");
    foreach (string path in tar.list_files()){
        inary.log.print(path);
    }
    tar.extract("aaa");
    tar.extract_all();
    stdout.printf("--------------\n");
    
    // file test
    inary.log.warning(readfile("/proc/cmdline"));
    stdout.printf("--------------\n");
    
    //inifile test
    var ini = new inifile();
    ini.load("../test/example/test.ini");
    inary.log.warning(ini.get("main","test"));
    inary.log.warning(ini.get_sections()[0]);
    inary.log.warning(ini.get_variables("devel")[0]);
    stdout.printf("--------------\n");
    
    // settings test
    set_destdir("../test/example/rootfs");
    inary.log.print("jobs="+inary.config.jobs);
    
    // logger test
    inary.log.error_add("Hello World");
    #if DEBUG
    inary.log.error_add("Test 123");
    #endif
    
    // command test
    string i = getoutput("echo -n hmmm");
    inary.log.debug(i.to_string());
    inary.log.debug(run_silent("non-command -non-parameter").to_string());
    run("non-command -non-parameter");
    
    inary.log.error(0);
    inary.log.error(1);
    stdout.printf("--------------\n");
    
}
