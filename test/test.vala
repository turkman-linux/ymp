
string tmp;
void main (string[] args) {
    // init ymp
    Ymp ymp = ymp_init (args);
    print ("Ymp test");
    set_destdir ("../test/rootfs");
    ymp.add_process ("init", {"hello", "world"});
    ymp.run ();

    //yesno test
    print ("Interface test");
    yesno ("Yes or no");

    // archive test
    print ("Archive test");
    var tar = new archive ();
    tar.load ("../test/data/main.tar.gz");
    tar.list_files ();
    tar.set_target ("./test/");
    tar.extract ("main.c");
    tar.readfile ("main.c");
    tar.extract_all ();

    // file test
    print ("File test");
    readfile ("./test/main.c");
    string curdir = pwd ();
    cd ("..");

    // directory test
    create_dir ("test/dir");
    remove_dir ("test/dir");
    cd (curdir);
    find ("./test");
    create_dir ("test/dir");
    writefile ("test/dir/test.txt", "ymp");
    remove_all ("test");
    pwd ();

    // logger test
    print ("Logging test");
    debug ("debug test");

    // command test
    print ("Command test");
    tmp = getoutput ("./test/hello.py");
    run_silent ("non-command -non-parameter");
    run ("false");

    // package test
    print ("Package test");
    var pkg1 = new package ();
    pkg1.load ("../test/data/metadata-binary.yaml");

    // string test
    tmp = join (", ", {"aaa", "bbb"});
    sbasename ("test/dir");
    sdirname ("test/dir");

    // index test
    print ("Repository test");
    get_repos ();

    //array test
    print ("Array test");
    var a = new array ();
    a.add ("aa");
    a.add ("bb");
    a.add ("cc");
    a.reverse ();
    a.pop (0);
    a.remove ("aa");
    a.has ("bb");
    a.insert ("dd", 0);
    a.set ({"yumusak", "ge"});
    a.get ();

    // Binary test
    print ("Binary test");
    iself ("ymp-test");
    is64bit ("libymp.so");
    print (calculate_sha1sum ("ymp-cli"));

    // ttysize test
    print ("C functions test");
    tty_size_init ();
    get_tty_width ();
    get_tty_height ();

    // which test
    which ("bash");

    // users test
    get_uid_by_user ("root");
    switch_user ("root");

    // value test
    print ("value test");
    get_value ("interactive");
    set_bool ("shellmode", true);
    error_add ("Error test");
    has_error ();

    // brainfuck test
    print ("Brainfuck test");
    string bfcode = readfile ("../test/data/hello.bf");
    brainfuck (bfcode, 102400);
    print ("done");
}
