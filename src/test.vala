logger log;
void main(){
    log = new logger();
    // archive test
    var tar = new archive();
    tar.load("../example/main.tar.gz");
    foreach (string path in tar.list_files()){
        log.print(path);
    }
    tar.extract("aaa");
    tar.extract_all();
    stdout.printf("--------------\n");
    
    // file test
    log.warning(readfile("/proc/cmdline"));
    stdout.printf("--------------\n");
    
    //inifile test
    var ini = new inifile();
    ini.load("../example/test.ini");
    log.warning(ini.get("main","test"));
    log.warning(ini.get_sections()[0]);
    log.warning(ini.get_variables("devel")[0]);
    stdout.printf("--------------\n");
    
    // logger test
    log.error_add("Hello World");
    #if DEBUG
    log.error_add("Test 123");
    #endif
    string i = getoutput("echo -n hmmm");
    log.debug(i.to_string());
    log.debug(run_silent("non-command -non-parameter").to_string());
    run("non-command -non-parameter");
    log.error(0);
    log.error(1);
    stdout.printf("--------------\n");
}
