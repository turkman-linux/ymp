
void main(){
    // init inary
    set_destdir("../test/example/rootfs");
    Inary inary = inary_init();
    inary.add_process("echo",{"hello","world"});
    inary.run();
    // archive test
    var tar = new archive();
    tar.load("../test/example/main.tar.gz");
    foreach (string path in tar.list_files()){
        print(path);
    }
    tar.extract("aaa");
    tar.set_target("./ffff/");
    tar.extract_all();
    stdout.printf("--------------\n");
    
    // file test
    warning(readfile("/proc/cmdline"));
    run("pwd");
    string curdir = pwd();
    cd("..");
    create_dir("uuu");
    remove_dir("uuu");
    run("pwd");
    cd(curdir);
    warning(pwd());
    stdout.printf("--------------\n");
    //yamlfile test
    var yaml = new yamlfile();
    yaml.load("../test/example/metadata-source.yaml");
    var metadata = yaml.get("inary.source");
    print(metadata);
    stdout.printf("--------------\n");
    //inifile test
    var ini = new inifile();
    ini.load("../test/example/test.ini");
    warning(ini.get("main","test"));
    warning(ini.get_sections()[0]);
    warning(ini.get_variables("devel")[0]);
    stdout.printf("--------------\n");
    
    // settings test
    set_destdir("../test/example/rootfs");
    print("jobs="+inary.config.jobs);
    
    // logger test
    error_add("Hello World");
    #if DEBUG
    error_add("Test 123");
    #endif
    
    // command test
    string i = getoutput("echo -n hmmm");
    debug(i.to_string());
    debug(run_silent("non-command -non-parameter").to_string());
    run("non-command -non-parameter");

    // help test
    help();    
    error(0);
    error(1);
    stdout.printf("--------------\n");
}
