public int httpd_main (string[] args) {
    return start_httpd ();
}

void httpd_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (httpd_main);
    op.names = {_ ("httpd"), "httpd"};
    op.help.name = _ ("httpd");
    op.help.description = _ ("Simple http server.");
    op.help.add_parameter ("--port", _ ("port number"));
    op.help.add_parameter ("--allow", _ ("allowed clients  (0.0.0.0 for allow everyone)"));
    add_operation (op);
}
