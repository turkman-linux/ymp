//DOC: ## File functions
//DOC: File & Directory functions

//DOC: `string readfile_byte (string path, long size):`
//DOC: read **n** byte from file
public string readfile_byte (string path, uint64 n) {
    debug (_ ("Read file bytes: %s").printf (path));
    if (!isfile (path)) {
        return "";
    }
    uint64 size = filesize(path);
    FileStream stream = FileStream.open (path, "r");
    if (stream == null) {
        warning (_ ("Failed to read file: %s").printf (path));
        return "";
    }

    if (size == 0) {
        warning (_ ("File is empty: %s").printf (path));
        return "";
    }else if (size < n) {
        warning (_ ("Read byte size is bigger than file size: %s (read: %" + uint64.FORMAT + " size: %" + uint64.FORMAT+")").printf (path, n, size));
        return "";
    }else if (n == 0) {
        n = size;
    }

    // load content:
    uint8[] buf = new uint8[n];
    size_t read = stream.read (buf, 1);
    if (n != read) {
        return "";
    }
    return (string) buf;
}


//DOC: `string readfile (string path):`
//DOC: read file from **path** and remove commends
public string readfile (string path) {
    debug (_ ("Read file: %s").printf (path));
    if (!isfile (path)) {
        return "";
    }
    string data = readfile_raw (path);
    if (data.length == 0) {
        return "";
    }
    array a = new array();
    debug (_ ("Remove commend lines: %s").printf (path));
    foreach (string line in ssplit (data, "\n")) {
        if ("#" in line) {
            if (line.strip ()[0] == '#') {
                continue;
            }
            line = ssplit (line, "#")[0];
            if (line.strip () != "") {
                a.add(line);
                a.add("\n");
            }
        }else {
            if (line.length > 0) {
                a.add(line);
                a.add("\n");
            }
        }
    }
    return a.get_string();
}

private variable[] cached_files;

public string readfile_cached(string path){
    if(cached_files == null) {
        cached_files = {};
    }
    foreach (variable x in cached_files) {
        if (x.name == path) {
            info(_ ("Read file from cache %s").printf(path));
            return x.value;
        }
    }
    variable v = new variable();
    v.name = path;
    v.value = readfile_raw(path);
    cached_files += v;
    return v.value;
}

public void file_cache_reset(){
    cached_files = {};
}

//DOC: `string safedir (string dir):`
//DOC: directory safe for httpd
public extern string safedir (string dir);

// libc function (from stdio.h)
public extern int remove (string path);
public extern int rmdir (string path);

//DOC: `int remove_dir (string path)`
//DOC: remove **path** directory
public int remove_dir (string path) {
    debug (_ ("Remove directory: %s").printf (path));
    if (!isdir (path)) {
        return 0;
    }
    #if experimental
    return GLib.DirUtils.remove (path);
    #else
    return rmdir (path);
    #endif
}

//DOC: `int remove_file (string path)`
//DOC: remove **path** file
public int remove_file (string path) {
    debug (_ ("Remove file: %s").printf (path));
    if (!isfile (path)) {
        return 0;
    }
    #if experimental
    try {
        File file = File.new_for_path (path);
        // remove file content on disk
        if (!issymlink (path)) {
            file.replace_contents ("\0x00".data, null, false, FileCreateFlags.NONE, null);
        }
        file.delete ();
        return 0;
    }catch (Error e) {
        error_add (e.message);
        return -1;
    }
    #else
    return remove (path);
    #endif
}
//DOC: `int remove_all (string path):`
//DOC: Remove files and directories (like **rm -rf**)
public int remove_all (string path) {
    var inodes = new array ();
    inodes.set (find (path));
    foreach (string inode in inodes.get ()) {
        if (isfile (inode)) {
            remove_file (inode);
        }
    }
    inodes.reverse ();
    foreach (string inode in inodes.get ()) {
        if (isdir (inode)) {
            remove_dir (inode);
        }
    }
    return 0;
}

//DOC: `void move_file (stirg src, string desc):`
//DOC: move **src** file to **desc**
public void move_file (string src, string desc) {
    debug (_ ("Move: %s => %s").printf (src, desc));
    GLib.File dest_file = GLib.File.new_for_path (src);
    GLib.File src_file = GLib.File.new_for_path (desc);
    if (isfile (desc)) {
        remove_file (desc);
    }
    if (!isfile (src)) {
        return;
    }
    try {
        dest_file.move (src_file, FileCopyFlags.NONE, null);
    } catch (Error e) {
        error_add (_ ("Failed to move file: %s => %s").printf (src, desc));
        error_add (e.message);
    }
}

//DOC: `void copy_file (string src, string desc):`
//DOC: copy **src** file to **desc**. File permissions and owners are ignored.
public void copy_file (string src, string desc) {
    debug (_ ("Copy: %s => %s").printf (src, desc));
    File file1 = File.new_for_path (src);
    File file2 = File.new_for_path (desc);
    create_dir (sdirname (desc));
    int64 sync_bytes = 0;
    if("://" in src){
        if(!fetch(src, desc)){
            error_add (_ ("Failed to fetch file: %s => %s").printf (src, desc));
        }
        return;
    }
    if (isfile (desc)) {
        remove_file (desc);
    }
    if (!isfile (src)) {
        return;
    }
    try {
        file1.copy (file2, 0, null, (cur, total) => {
            // call sync every 20mb
            if (cur - sync_bytes > 20 * 1024 * 1024) {
                fs_sync ();
                sync_bytes = cur;
            }
        });
        print_stderr ("");
        fs_sync ();
    } catch (Error e) {
        error_add (_ ("Failed to copy file: %s => %s").printf (src, desc));
        error_add (e.message);
    }
}

//DOC: `string[] listdir (string path):`
//DOC: list directory content and result as array
public string[] listdir (string path) {
    debug (_ ("List directory: %s").printf (path));
    string[] ret = {};
    string name;
    try {
        Dir dir = Dir.open (path + "/", 0);
        while ( (name = dir.read_name ()) != null) {
            ret += name;
        }

    }catch (Error e) {
        warning (e.message);
        return {};
    }
    return ret;
}

//DOC: `bool iself (string path):`
//DOC: return true if file is elf binary
public bool iself (string path) {
    debug (_ ("Check elf: %s").printf (path));
    if (!isfile (path)) {
        return false;
    }
    uint64 size = filesize(path);
    if(size < 4){
        return false;
    }
    var ctx = readfile_byte (path, 4);
    // .ELF magic bytes
    if (ctx == "") {
        return false;
    }
    return startswith (ctx, "\x7F\x45\x4C\x46");
}

//DOC: `bool is64bit (string path):`
//DOC: return true if file is elf binary
public bool is64bit (string path) {
    debug (_ ("Check 64bit: %s").printf (path));
    if (!isfile (path)) {
        return false;
    }
    
    uint64 size = filesize(path);
    if(size < 4){
        return false;
    }

    var ctx = readfile_byte (path, 4);
    // first byte after magic is bit size flag
    // 01 = 32bit 02 = 64bit
    if (ctx == "") {
        return false;
    }
    return ctx[4] == '\x02';
}


public bool isexists (string path) {
    debug (_ ("Check exists: %s").printf (path));
    var file = File.new_for_path (path);
    return file.query_exists ();
}
extern string c_realpath (string path);

//DOC: `string srealpath (string path):`
//DOC: safe realpath function.
public string srealpath (string path) {
    debug (_ ("Realpath: %s").printf (path));
    if (path == null || path == "" || path == "/") {
        return "/";
    }
    string real = path;
    if ("/../" in path || !startswith (path, "/")) {
        real = c_realpath (path);
    }
    if (real == null || real == "") {
        return path;
    }
    return real;
}

public static string p_realpath (string path) {
    string[] p = ssplit (path, "/");
    string cur = DESTDIR + "/";
    foreach (string dir in p) {
        if (issymlink (cur + dir)) {
            string link = sreadlink (cur + dir);
            if (!startswith (link, "/")) {
                cur += link;
            }else {
                cur = link;
            }
        }else {
            cur += dir;
        }
        if (isfile (cur)) {
            return safedir(cur);
        }
        cur += "/";
    }
    return safedir(cur);;
}

private string get_fixed_symlink(string source, string target){
   debug (_ ("Calculate fixed symlink: %s -> %s").printf (source, target));
   string[] source_items = ssplit(source,"/");
   string ret = "";
   for(int i=source_items.length -1 ; i>0 ; i--){
       ret += "../";
   }
   if (target[0] == '/'){
       if(ret.length == 0 ){
           ret += ".";
       }else{
           ret = ret[:ret.length-1];
       }
   }
   ret += target;
   return ret;
}

//DOC: `string[] find (string path):`
//DOC: find file and directories with parents
public string[] find (string path) {
    debug (_ ("Search: %s").printf (path));
    find_ret = {};
    if (path == "" || path == null) {
        return {
};
    }
    find_operation (path);
    return find_ret;
}
private string[] find_ret;
private void find_operation (string path) {
    if (path == "" || path == null || path == ".." || path == ".") {
        return;
    }
    find_ret += path;
    if (isdir (path)) {
        debug (_ ("Search subdir: %s").printf (path));
        foreach (string p in listdir (path)) {
            find_operation (path + "/" + p);
        }
    }
}

//DOC: `string calculate_sha1sum (string path):`
//DOC: calculate sha1sum value from file path
public string calculate_sha1sum (string path) {
    return calculate_checksum (path, ChecksumType.SHA1);
}

//DOC: `string calculate_sha1sum (string path):`
//DOC: calculate sha1sum value from file path
public string calculate_sha256sum (string path) {
    return calculate_checksum (path, ChecksumType.SHA256);
}

//DOC: `string calculate_md5sum (string path):`
//DOC: calculate md5sum value from file path
public string calculate_md5sum (string path) {
    return calculate_checksum (path, ChecksumType.MD5);
}

public string sreadlink (string path) {
    if (issymlink (path)) {
       try {
          string link = GLib.FileUtils.read_link (path);
          debug (_ ("Read symlink: %s => %s").printf (path, link));
          return link;
       }catch (Error e) {
           warning (e.message);
           return "";
       }
    }
    return "";
}

//DOC: `bool is_empty_dir (string path):`
//DOC: check path is empty directory
public bool is_empty_dir (string path) {
    if (!isdir (path)) {
        return false;
    }
    return listdir (path).length == 0;
}

//DOC: `string calculate_checksum (string path, ChecksumType type):`
//DOC: calculate checksum value from file path and checksum type
public string calculate_checksum (string path, ChecksumType type) {
    if (!isfile (path)) {
        return "";
    }
    if (issymlink (path) && sreadlink (path) == "") {
        return "";
    }
    debug (_ ("Calculating checksum: %s").printf (path));
    Checksum checksum = new Checksum (type);
    FileStream stream = FileStream.open (path, "rb");
    uint8 fbuf[100];
    size_t size;
    while ( (size = stream.read (fbuf)) > 0) {
        checksum.update (fbuf, size);
    }
    return checksum.get_string ();
}
