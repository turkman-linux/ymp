public int httpd_main (string[] args) {
    string cur = pwd();
    string source = get_value("source");
    if(source != ""){
        cd(source);
    }
    int status = start_httpd ();
    cd(cur);
    return status;
}

void httpd_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (httpd_main);
    op.names = {_ ("httpd"), "httpd"};
    op.help.name = _ ("httpd");
    op.help.description = _ ("Simple http server.");
    op.help.add_parameter ("--port", _ ("port number"));
    op.help.add_parameter ("--source", _ ("source directory"));
    op.help.add_parameter ("--allow", _ ("allowed clients (0.0.0.0 for allow everyone)"));
    add_operation (op);
}
