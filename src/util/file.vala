//DOC: ## File functions
//DOC: File & Directory functions

//DOC: `string readfile_raw (string path):`
//DOC: Read file from **path** and return content
public string readfile_raw (string path){
    if(!isfile(path)){
        warning("File not found: "+path);
        return "";
    }
    FileStream stream = FileStream.open (path, "r");
    if(stream == null){
	    warning("Failed to read file: "+path);
	    return "";
	}

	// get file size:
	stream.seek (0, FileSeek.END);
	long size = stream.tell ();
	stream.rewind ();
	if(size == 0){
	    string data = readfile_raw2(path);
	    if(data != ""){
	        return data;
	    }
	    warning("File is empty: "+path);
	    return data;
	}

	// load content:
	uint8[] buf = new uint8[size];
	size_t read = stream.read (buf, 1);
	assert (size == read);

	return (string) buf;
}

//DOC: `string readfile_raw2 (string path):`
//DOC: Read file from **path** and return content
private string readfile_raw2 (string path){
    File file = File.new_for_path (path);
    string data="";
    try {
        FileInputStream @is = file.read ();
        DataInputStream dis = new DataInputStream (@is);
        string line;
        while ((line = dis.read_line ()) != null){
            data += line+"\n";
            debug("Read line from:"+path);
        }
    } catch (Error e) {
        error_add(e.message);
        return "";
    }
    return data;
}


//DOC: `string readfile_byte(string path, long size):`
//DOC: read **n** byte from file
public string readfile_byte(string path, long n){
    if(!isfile(path)){
        return "";
    }
    FileStream stream = FileStream.open (path, "r");
	if(stream == null){
	    warning("Failed to read file: "+path);
	    return "";
	}

	// get file size:
	stream.seek (0, FileSeek.END);
	long size = stream.tell ();
	stream.rewind ();
	if(size == 0){
	    warning("File is empty: "+path);
	    return "";
	}else if(size < n){
	    warning("Read byte size bigger than file size: "+path);
	    print(size.to_string()+ " "+ n.to_string());
	    return "";
	}else if(n == 0){
	    n = size;
	}

	// load content:
	uint8[] buf = new uint8[n];
	size_t read = stream.read (buf, 1);
	assert (n == read);
	return (string) buf;
}


//DOC: `string readfile(string path):`
//DOC: read file from **path** and remove commends
public string readfile(string path){
    string new_data = "";
    foreach(string line in ssplit(readfile_raw(path),"\n")){
        if(line.length > 0){
            new_data += ssplit(line,"#")[0]+"\n";
        }
    }
    return new_data;
}

//DOC: `void writefile(string path, string ctx):`
//DOC: write **ctx** data to **path** file
public void writefile(string path, string ctx){
    string dir = sdirname(path);
    create_dir(dir);
    try {
        var file = File.new_for_path (path);
        if (file.query_exists ()) {
            file.delete ();
        }
        var dos = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
        uint8[] data = ctx.data;
        long written = 0;
        while (written < data.length) {
            written += dos.write (data[written:data.length]);
        }
    } catch (Error e) {
        error_add(e.message);
    }
}

//DOC: `void cd(string path):`
//DOC: change current directory to **path**
public void cd(string path){
    if(!isdir(path)){
        create_dir(path);
    }
    GLib.Environment.set_current_dir(path);
}

//DOC: `string pwd():`
//DOC: return current directory path
public string pwd(){
    return GLib.Environment.get_current_dir();
}

//DOC: `int remove_dir(string path)`
//DOC: remove **path** directory
public int remove_dir(string path){
    debug("Remove directory: "+path);
    return GLib.DirUtils.remove(path);
}

//DOC: `int remove_file(string path)`
//DOC: remove **path** file
public int remove_file(string path){
    debug("Remove file: "+path);
    File file = File.new_for_path(path);
    try {
        file.delete();
        return 0;
    }catch (Error e){
        return -1;
    }
}
//DOC: `int remove_all(string path):`
//DOC: Remove files and directories (like **rm -rf**)
public int remove_all(string path){
    var inodes = new array();
    inodes.set(find(path));
    foreach(string inode in inodes.get()){
        if(isfile(inode)){
            remove_file(inode);
        }
    }
    inodes.reverse();
    foreach(string inode in inodes.get()){
        if(isdir(inode)){
            remove_dir(inode);
        }
    }
    return 0;
}

//DOC: `void move_file(stirg src, string desc):`
//DOC: move **src** file to **desc**
public void move_file(string src, string desc){
    debug("Move: "+src +" => "+desc);
    GLib.File dest_file = GLib.File.new_for_path(src);
    GLib.File src_file = GLib.File.new_for_path(desc);
    if(isfile(desc)){
        remove_file(desc);
    }
    try {
        dest_file.move(src_file, FileCopyFlags.NONE, null);
    } catch (Error e) {
        error_add("Failed to move file: "+src + " => "+desc);
        error_add(e.message);
    }
}

//DOC: `void copy_file(string src, string desc):`
//DOC: copy **src** file to **desc**. File permissions and owners are ignored.
public void copy_file(string src, string desc){
    debug("Copy: "+src +" => "+desc);
    writefile(desc,readfile_raw(src));
}

//DOC: `string[] listdir(string path):`
//DOC: list directory content and result as array
public string[] listdir(string path){
    string[] ret = {};
    string name;
    try{
        Dir dir = Dir.open(path+"/", 0);
        while ((name = dir.read_name ()) != null) {
            ret += name;
        }

    }catch(Error e){
        warning(e.message);
        return {};
    }
    return ret;
}

//DOC: `bool iself(string path):`
//DOC: return true if file is elf binary
public bool iself(string path){
    var ctx = readfile_byte(path,4);
    // .ELF magic bytes
    if(ctx == ""){
        return false;
    }
    return startswith(ctx,"\x7F\x45\x4C\x46");
}

//DOC: `bool is64bit(string path):`
//DOC: return true if file is elf binary
public bool is64bit(string path){
    var ctx = readfile_byte(path,4);
    // first byte after magic is bit size flag
    // 01 = 32bit 02 = 64bit
    if(ctx == ""){
        return false;
    }
    return ctx[4] == '\x02';
}

public bool isfile(string path){
    return GLib.FileUtils.test(srealpath(path), GLib.FileTest.IS_REGULAR) || 
               GLib.FileUtils.test(path, GLib.FileTest.IS_SYMLINK);
}

public bool issymlink(string path){
    return GLib.FileUtils.test(path, GLib.FileTest.IS_SYMLINK);
}

//DOC: `bool isdir(string path):`
//DOC: Check **path** is directory
public bool isdir(string path){
    return GLib.FileUtils.test(path, GLib.FileTest.IS_DIR) &&
    ! GLib.FileUtils.test(path, GLib.FileTest.IS_SYMLINK);
}

//DOC: `string srealpath(string path):`
//DOC: safe realpath function.
public string srealpath(string path){
    string real = Posix.realpath(path);
    if(real == null){
        return path;
    }
    return real;
}

//DOC: `string[] find(string path):`
//DOC: find file and directories with parents
public string[] find(string path){
    debug("Search: "+path);
    find_ret = {};
    if(path == "" || path == null){
        return {};
    }
    find_operation(path);
    return find_ret;
}
private string[] find_ret;
private void find_operation(string path){
    if(path == "" || path == null){
        return;
    }
    find_ret += path;
    if(isdir(path)){
        debug("Search subdir: "+path);
        foreach(string p in listdir(path)){
            find_operation(path+"/"+p);
        }
    }
}

//DOC: `string calculate_sha1sum(string path):`
//DOC: calculate sha1sum value from file path
public string calculate_sha1sum(string path){
    return  calculate_checksum(path, ChecksumType.SHA1);
}

//DOC: `string calculate_md5sum(string path):`
//DOC: calculate md5sum value from file path
public string calculate_md5sum(string path){
    return  calculate_checksum(path, ChecksumType.MD5);
}

//DOC: `string calculate_checksum(string path, ChecksumType type):`
//DOC: calculate checksum value from file path and checksum type
public string calculate_checksum(string path, ChecksumType type){
    if(!isfile(path)){
        return "";
    }
    if(issymlink(path)){
        try{
            if(!isfile(GLib.FileUtils.read_link(path))){
                warning("broken symlink detected");
                return "";
            }
        }catch(Error e){
            warning(e.message);
            return "";
        }
    }
    info("Calculating checksum: "+path);
    Checksum checksum = new Checksum (type);
	FileStream stream = FileStream.open (path, "rb");
	uint8 fbuf[100];
	size_t size;
	while ((size = stream.read (fbuf)) > 0) {
		checksum.update (fbuf, size);
	}
	return checksum.get_string ();
}
