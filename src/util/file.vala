public string readfile (string path){
    File file = File.new_for_path (path);
    string data="";
    try {
        FileInputStream @is = file.read ();
        DataInputStream dis = new DataInputStream (@is);
        string line;
        while ((line = dis.read_line ()) != null){
            data += line+"\n";
            #if debug
            log.debug("Read line from:"+path)
            #endif
        }
    } catch (Error e) {
        if (log != null){
            log.error_add(e.message);
        }else{
            stderr.printf(e.message);
        }
        return "";
    }
    return data;
}
