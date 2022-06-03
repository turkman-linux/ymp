
void main(string[] args){
    // init inary
    set_destdir("../test/example/rootfs");
    Inary inary = inary_init(args);
    
    inary.add_process("echo",{"hello","world"});
    inary.run();

    //yesno test
    if(yesno("Fff")){
        print("Yes accept");
    }else{
        error_add("no selected");
        error(1);
    }

    // archive test
    var tar = new archive();
    tar.load("../test/example/main.tar.gz");
    foreach (string path in tar.list_files()){
        print(path);
    }
    tar.extract("aaa");
    var aaa = tar.readfile("aaa");
    print(aaa);
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
    print(yaml.get_value(metadata,"name"));
    print(yaml.get_array(metadata,"archive")[0]);
    print(metadata);
    stdout.printf("--------------\n");
    //inifile test
    var ini = new inifile();
    ini.load("../test/example/test.ini");
    warning(ini.get("main","test"));
    warning(ini.get_sections()[0]);
    warning(ini.get_variables("devel")[0]);
    stdout.printf("--------------\n");
    
    
    // logger test
    error_add("Hello World");
    #if DEBUG
    debug("Test 123");
    #endif
    
    // command test
    string i = getoutput("echo -n hmmm");
    debug(i.to_string());
    debug(run_silent("non-command -non-parameter").to_string());
    run("non-command -non-parameter");

    // package test
    var pkg1 = new package();
    pkg1.load("../test/example/metadata-binary.yaml");
    warning(pkg1.name);
    foreach (string name in pkg1.dependencies){
        print(name);
    }

    print(join(", ",{"aaa","bbb"}));
    var pkg2 = get_installed_packege("aaa");
    stdout.printf("--------------\n");

    var pkg3 = new package();
    pkg3.load_from_archive("../test/example/package.inary");
    warning(pkg3.name);
    foreach(string file in pkg3.list_files()){
        print(file);
    }
    pkg3.extract();

    // index test
    repository[] repos = get_repos();
    foreach(repository repo in repos){
        print(repo.name);
        foreach(string area in repo.packages){
            var pkg = new package();
            pkg.load_from_data(area);
            foreach(string dep in pkg.dependencies){
                warning(dep);
            }
            print(pkg.get("name"));
        }
    }
    stdout.printf("--------------\n");

    // binary test
    if(iself("inary-test")){
        print("binary test");
    }
    if(is64bit("inary")){
        print("64bit build detected");
    }

    //ttysize test
    tty_size_init();
    print(get_tty_width().to_string()+"x"+get_tty_height().to_string());

    // value test
    print(get_value("interactive"));  
    error(0);
    error_add("Test 123");
    error(1);
    stdout.printf("--------------\n");
}
