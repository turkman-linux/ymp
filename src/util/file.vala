public string readfile_raw (string path){
    File file = File.new_for_path (path);
    string data="";
    try {
        FileInputStream @is = file.read ();
        DataInputStream dis = new DataInputStream (@is);
        string line;
        while ((line = dis.read_line ()) != null){
            data += line+"\n";
            #if debug
            debug("Read line from:"+path)
            #endif
        }
    } catch (Error e) {
        error_add(e.message);
        return "";
    }
    return data;
}
public string readfile(string path){
    string new_data = "";
    foreach(string line in readfile_raw(path).split("\n")){
        new_data += line.split("#")[0]+"\n";
    }
    return new_data;
}

public void cd(string path){
    GLib.Environment.set_current_dir(path);
}

public string pwd(){
    return GLib.Environment.get_current_dir();
}

public int create_dir(string path){
    return GLib.DirUtils.create_with_parents(path,0755);
}

public int remove_dir(string path){
    return GLib.DirUtils.remove(path);
}

public int remove_file(string path){
    File file = File.new_for_path(path);
    try {
        file.delete();
        return 0;
    }catch (Error e){
        return -1;
    }
}
