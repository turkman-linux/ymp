private bool on_incoming_connection(SocketConnection conn) {
    process_request.begin(conn);
    return true;
}
private long BUFFER_LENGTH = 1024*100;
async void process_request(SocketConnection conn) {
    try {
        var dis = new DataInputStream(conn.input_stream);
        var dos = new DataOutputStream(conn.output_stream);
        var now = new DateTime.now_local ();
        string req = "";
        string path = "";
        while(!startswith(req,"GET")){
            req = yield dis.read_line_async(Priority.HIGH_IDLE);
            debug(req);
        }
        path = safedir(req.split(" ")[1]);
        if(isdir(path) && isfile(path+"/index.html")){
            path = path+"/index.html";
        }
        InetSocketAddress local = conn.get_remote_address() as InetSocketAddress;
        string ip = local.get_address().to_string();
        string date = now.format("%H:%M %Y.%m.%d");
        if (isfile(path)) {
            FileStream stream = FileStream.open(path, "r");
            long size = filesize(path);

            print_fn("%s -- %s %s %s".printf(ip,date,path,GLib.format_size((uint64)size)),true,true);

            dos.put_string("HTTP/1.1 200 OK\n");
            dos.put_string("Server: YMP httpd %s\n".printf(VERSION));
            if(endswith(path.down(),".html")){
                dos.put_string("Content-Type: text/html\n");
            }else{
                dos.put_string("Content-Type: text/plain\n");
            }
            dos.put_string("Content-Length: %l\n\n".printf(size));
            uint8[] buf = new uint8[BUFFER_LENGTH];
            size_t read_size = 0;
            size_t written = 0;
            while ((read_size = stream.read (buf)) != 0) {
               written = 0;
               while(written < read_size){
                   written += dos.write(buf[written:read_size]);
               }
               dos.flush();
            }
        }else if(isdir(path)){
            dos.put_string("HTTP/1.1 200 OK\nContent-Type: text/html\n\n");
            dos.put_string("<html>\n<head>");
            dos.put_string("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n");
            dos.put_string("<title>Directory listing for "+path[1:]+"</title>\n");
            dos.put_string("</head>\n<body>\n");
            dos.put_string("<h1>Directory listing for "+path[1:]+"</h1>\n");
            dos.put_string("<hr>\n<ul>\n");
            dos.put_string("<li><a href=\"../\">..</a><br></li>\n");
            dos.flush();
            foreach(string f in listdir(path)){
                string v="";
                if(isdir(f)){
                    v="/";
                }
                string ff = f.replace(">","&gt;").replace("<","&lt;")+v;
                dos.put_string("<li><a href=\""+path+"/"+f+"\">"+ff+"</a><br></li>\n");
                dos.flush();
            }
            dos.put_string("</ul>\n<hr>\n");
            dos.put_string("</body>\n</html>");
        }else{
            dos.put_string("HTTP/1.1 404 Not Found\nContent-Type: text/html\n");
            dos.flush();
        }
    } catch (Error e) {
        warning(e.message);
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
        print_fn("Servering HTTP on 0.0.0.0 port %s".printf(port.to_string()),true,true);
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
