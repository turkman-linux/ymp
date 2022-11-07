private bool on_incoming_connection(SocketConnection conn) {
    process_request.begin(conn);
    return true;
}

async void process_request(SocketConnection conn) {
    try {
        var dis = new DataInputStream(conn.input_stream);
        var dos = new DataOutputStream(conn.output_stream);
        var now = new DateTime.now_local ();
        string req = yield dis.read_line_async(Priority.HIGH_IDLE);
        string path = safedir(req.split(" ")[1]);
        if(endswith(path,".html")){
            dos.put_string("HTTP/1.1 200 OK\nContent-Type: text/html\n\n");
        }else{
            dos.put_string("HTTP/1.1 200 OK\nContent-Type: text/plain\n\n");
        }
        if (path == ".//") {
            path = "./index.html";
        }
        InetSocketAddress local = conn.get_remote_address() as InetSocketAddress;
        string ip = local.get_address().to_string();
        string date = now.format("%H:%M %Y.%m.%d");
        print_fn("%s -- %s %s".printf(ip,date,path),true,true);
        if (isfile(path)) {
            FileStream stream = FileStream.open(path, "r");
            long size = filesize(path);
            // load content:
            uint8[] buf = new uint8[size];
            size_t read_size = stream.read(buf, 1);
            if (size != read_size) {
                return;
            }
            dos.write(buf);
            dos.flush();
        }
    } catch (Error e) {
        error_add(e.message);
        error(2);
    }
}

public int httpd_main(string[] args) {
    int port = 8000;
    if (get_value("port") != "") {
        port = int.parse(get_value("port"));
    }
    try {
        var srv = new SocketService();
        srv.add_inet_port((uint16)port, null);
        srv.incoming.connect(on_incoming_connection);
        srv.start();
        new MainLoop().run();
    } catch (Error e) {
        error_add(e.message);
        error(2);
    }
    return 0;
}
void httpd_init() {
    var h = new helpmsg();
    h.name = "httpd";
    h.description = "Simple http server";
    add_operation(httpd_main, {"httpd"}, h);
}
