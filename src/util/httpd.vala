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
        string path = "/";
        req = yield dis.read_line_async(Priority.HIGH_IDLE);
        if(!startswith(req,"GET")){
            return;
        }
        if(req!=null && req.length>=4){
            path = url_decode(safedir(ssplit(req," ")[1]));
            while(startswith(path,"/")){
                path = path[1:];
            }
        }else{
            return;
        }
        print(path);
        if(isdir(path) && isfile(path+"/index.html")){
            path = path+"/index.html";
        }
        InetSocketAddress local = conn.get_remote_address() as InetSocketAddress;
        string ip = local.get_address().to_string();
        string acl = get_value("allow");
        if(acl == ""){
            acl = "127.0.0.1";
        }
        string[] acls = ssplit(acl,":");
        if(! (ip in acls) && ! ("0.0.0.0" in acls)){
            return;
        }
        string date = now.format("%H:%M %Y.%m.%d");
        if (isfile("./"+path)) {
            FileStream stream = FileStream.open("./"+path, "r");
            if(stream == null){
                dos.put_string("HTTP/1.1 403 Forbidden\n");
                return;
            }
            long size = filesize(srealpath("./"+path));

            print_fn("%s -- %s %s %s".printf(ip,date,srealpath("./"+path),GLib.format_size((uint64)size)),true,true);

            dos.put_string("HTTP/1.1 200 OK\n");
            dos.put_string("Server: YMP httpd %s\n".printf(VERSION));
            dos.put_string("Content-Type: "+get_content_type("./"+path)+"\n");
            dos.put_string("Content-Length: %s\n\n".printf(size.to_string()));
            debug("Content-Length: %s\n\n".printf(size.to_string()));
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
        }else if(isdir("./"+path)){
            print_fn("%s -- %s %s 0 bytes".printf(ip,date,srealpath("./"+path)),true,true);
            dos.put_string("HTTP/1.1 200 OK\nContent-Type: text/html\n\n");
            dos.put_string("<html>\n<head>");
            dos.put_string("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n");
            dos.put_string("<title>"+_("Directory listing for %s").printf(path)+"</title>\n");
            dos.put_string("<style>.link { text-decoration: none;}</style>\n");
            dos.put_string("</head>\n<body>\n");
            dos.put_string("<h1>"+_("Directory listing for /%s").printf(path)+"</h1>\n");
            dos.put_string("<hr>\n<ul>\n");
            if(path != "/"){
                dos.put_string("&#x1F4C1; <a href=\"../\">..</a><br></li>\n");
            }
            dos.flush();
            var node = new array();
            node.adds(listdir("./"+path));
            node.sort();
            foreach(string f in node.get()){
                if(startswith(f,".") || " " in f){
                    continue;
                }
                if(isdir("./"+path+"/"+f)){
                    string ff = f.replace(">","&gt;").replace("<","&lt;");
                    print(path+f);
                    dos.put_string("&#x1F4C1; <a class=\"link\" href=\"/"+url_encode(path+f).replace("%2F","/")+"/\">"+ff+"/</a><br></li>\n");
                    dos.flush();
                }
            }
            foreach(string f in node.get()){
                if(startswith(f,".")){
                    continue;
                }
                if(isfile("./"+path+"/"+f)){
                    string ff = f.replace(">","&gt;").replace("<","&lt;");
                    long size = filesize("./"+path+"/"+f);
                    dos.put_string("&#x1F4C4; <a class=\"link\" href=\"/"+url_encode(path+f).replace("%2F","/")+"\">"+ff+"</a> ("+GLib.format_size((uint64)size)+")<br></li>\n");
                    dos.flush();
                }
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

private string get_content_type(string path){
    #if no_libmagic
    if(endswith(path.down(),".html")){
        return "text/html";
    }else if(endswith(path.down(),".css")){
        return "text/css";
    }else if(endswith(path.down(),".js")){
        return "text/javascript";
    }else if(endswith(path.down(),".png")){
        return "image/png";
    }else if(endswith(path.down(),".jpeg") || endswith(path.down(),".jpg")){
        return "image/jpeg";
    }else if(endswith(path.down(),".svg")){
        return "image/svg+xml";
    }else{
        return "text/plain";
    }
    #else
    return get_magic_mime_type(path);
    #endif
}

public int start_httpd() {
    int port = 8000;
    if (get_value("port") != "") {
        port = int.parse(get_value("port"));
    }
    try {
        var srv = new SocketService();
        srv.add_inet_port((uint16)port, null);
        srv.incoming.connect(on_incoming_connection);
        srv.start();
        string acl = get_value("allow");
        if(acl == ""){
            acl = "127.0.0.1";
        }
        print_fn(_("Servering HTTP on %s port %s").printf(acl, port.to_string()),true,true);
        new MainLoop().run();
    } catch (Error e) {
        error_add(e.message);
        error(2);
    }
    return 0;
}
