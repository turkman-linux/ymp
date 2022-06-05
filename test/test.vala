
void main(string[] args){
    // init inary
    print("Inary test");
    set_destdir("../test/example/rootfs");
    Inary inary = inary_init(args);
    inary.add_process("init",{"hello","world"});
    inary.run();

    //yesno test
    print("Interface test");
    yesno("Yes or no");

    // archive test
    print("Archive test");
    var tar = new archive();
    tar.load("../test/example/main.tar.gz");
    tar.list_files();
    tar.extract("aaa");
    tar.readfile("aaa");
    tar.set_target("./ffff/");
    tar.extract_all();
    
    // file test
    print("File test");
    readfile("/proc/cmdline");
    string curdir = pwd();
    cd("..");
    create_dir("uuu");
    remove_dir("uuu");
    cd(curdir);
    pwd();

    //yamlfile test
    print("Yaml test");
    var yaml = new yamlfile();
    yaml.load("../test/example/metadata-source.yaml");
    var metadata = yaml.get("inary.source");
    yaml.get_value(metadata,"name");
    yaml.get_array(metadata,"archive");

    //inifile test
    print("Ini test");
    var ini = new inifile();
    ini.load("../test/example/test.ini");
    ini.get("main","test");
    ini.get_sections()[0];
    ini.get_variables("devel")[0];

    // logger test
    print("Logging test");
    error_add("Hello World");
    debug("debug test");

    // command test
    print("Command test");
    getoutput("echo -n hmmm");
    run_silent("non-command -non-parameter");
    run("false");

    // package test
    print("Package test");
    var pkg1 = new package();
    pkg1.load("../test/example/metadata-binary.yaml");
    join(", ",{"aaa","bbb"});
    get_installed_packege("aaa");
    var pkg3 = new package();
    pkg3.load_from_archive("../test/example/package.inary");
    pkg3.list_files();
    pkg3.extract();

    // index test
    print("Repository test");
    repository[] repos = get_repos();
    repos[0].list_packages();

    // binary test
    print("Binary test");
    iself("inary-test");
    is64bit("inary");

    // ttysize test
    print("C functions test");
    tty_size_init();
    get_tty_width();
    get_tty_height();

    // which test
    which("bash");

    // users test
    get_uid_by_user("root");
    switch_user("root");

    // value test
    print("value test");
    get_value("interactive");
    error_add("Error test");
    error(0);

}
