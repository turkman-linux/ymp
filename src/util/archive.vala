#if no_libarchive
public class archive {

    private string archive_path;

    private string target_path;
    public void set_target(string path){
        if(path != null){
            target_path = path;
        }
    }

    public void load(string path){
        archive_path = path;
    }
    public string[] list_files (){
        return split(getoutput("tar -f --list '"+archive_path+"'"),"\n");
    }
    public void extract_all(){
        if (target_path == null){
            target_path = "./";
        }
        run_silent("tar -xf -C '"+target_path+"' '"+archive_path+"'");
    }
    public void extract(string path){
        if (target_path == null){
            target_path = "./";
        }
        run_silent("tar -xf -C '"+target_path+"' '"+archive_path+"' '"+path+"'");
    }
}
#else
public class archive {
    //DOC: ## class archive()
    //DOC: Load & extract archive files.
    //DOC: Example usage:
    //DOC: ```vala
    //DOC: var tar = new archive();
    //DOC: tar.load("/tmp/archive.tar.gz");
    //DOC: tar.extract_all();
    //DOC: ```

    Archive.Read archive;
    private string archive_path;
    private string target_path;

    //DOC: `void archive.load(string path):`
    //DOC: load archive file from **path**
    public void load(string path){
        archive_path = path;
        afilter = 0;
        aformat = 0;
    }
    private void load_archive(string path){
        archive = new Archive.Read();
        archive.support_filter_all ();
        archive.support_format_all ();
        if (archive.open_filename (archive_path, 10240) != Archive.Result.OK) {
            error_add("Error: " + archive.error_string ());
            error(archive.errno ());
        }
    }
    
    public bool is_archive(string path){
        archive = new Archive.Read();
        archive.support_filter_all ();
        archive.support_format_all ();
        if (archive.open_filename (path, 10240) != Archive.Result.OK) {
            return false;
        }
        return true;
    
    }
    //DOC: `string[] archive.list_files():`
    //DOC: Get archive file list
    public string[] list_files (){
        load_archive(archive_path);
        unowned Archive.Entry entry;
        string[] ret = {};
        while (archive.next_header (out entry) == Archive.Result.OK) {
            ret += entry.pathname ();
            archive.read_data_skip ();
        }
    return ret;
    }

    //DOC: `void archive.set_target(string path):`
    //DOC: Change target directory for extract
    public void set_target(string path){
        if(path != null){
            target_path = path;
        }
    }

    //DOC: `void archive.add(string path):`
    //DOC: Add a file to archive create list
    private string[] archive_add_list;
    public void add(string path){
        if(archive_add_list == null){
            archive_add_list = {};
        }
        archive_add_list += path;
    }
    
    //DOC: `void archive.create():`
    //DOC: Create archive.
    public void create(){
        write_archive(archive_path,archive_add_list);
    }

    //DOC: `void archive.extract(string path):`
    //DOC: Extract **path** file to target directory
    public void extract (string path) {
        load_archive(archive_path);
        Archive.ExtractFlags flags;
        flags = Archive.ExtractFlags.TIME;
        flags |= Archive.ExtractFlags.PERM;
        flags |= Archive.ExtractFlags.ACL;
        flags |= Archive.ExtractFlags.FFLAGS;

        Archive.WriteDisk extractor = new Archive.WriteDisk ();
        extractor.set_options (flags);
        extractor.set_standard_lookup ();

        unowned Archive.Entry entry;
        Archive.Result last_result;
        while ((last_result = archive.next_header (out entry)) == Archive.Result.OK) {
            if (entry.pathname() != path){
                continue;
            }
            #if DEBUG
            debug("Extracting: "+path);
            #endif

            if (target_path == null){
                target_path = "./";
            }
            entry.set_pathname(target_path+"/"+path);

            if (extractor.write_header (entry) != Archive.Result.OK) {
                error_add("Failed to write file: "+entry.pathname());
                continue;
            }

            uint8[] buffer = null;
            Posix.off_t offset;
            while (archive.read_data_block (out buffer, out offset) == Archive.Result.OK) {
                if (extractor.write_data_block (buffer, offset) != Archive.Result.OK) {
                    break;
                }
            }
        }
        fs_sync();
        error(3);
    }
    //DOC: `string archive.readfile(string path):`
    //DOC: Read **path** file to target directory
    public string readfile (string path) {
        load_archive(archive_path);

        string ret="";
        unowned Archive.Entry entry;
        Archive.Result last_result;
        while ((last_result = archive.next_header (out entry)) == Archive.Result.OK) {
            if (entry.pathname() != path){
                continue;
            }

            uint8[] buffer = null;
            Posix.off_t offset;
            while (archive.read_data_block (out buffer, out offset) == Archive.Result.OK) {
                ret+=@"$((string) buffer)";
            }
        }
        return ret;
    }


    //DOC: `void archive.extract_all()`
    //DOC: Extract all files to target
    public void extract_all(){
        load_archive(archive_path);
        Archive.ExtractFlags flags;
        flags = Archive.ExtractFlags.TIME;
        flags |= Archive.ExtractFlags.PERM;
        flags |= Archive.ExtractFlags.ACL;
        flags |= Archive.ExtractFlags.FFLAGS;

        Archive.WriteDisk extractor = new Archive.WriteDisk ();
        extractor.set_options (flags);
        extractor.set_standard_lookup ();

        unowned Archive.Entry entry;
        Archive.Result last_result;
        while ((last_result = archive.next_header (out entry)) == Archive.Result.OK) {
            if (target_path == null){
                target_path = "./";
            }
            info("Extracting: "+entry.pathname());
            entry.set_pathname(target_path+"/"+entry.pathname());
            if (extractor.write_header (entry) != Archive.Result.OK) {
                error_add("Failed to write file: "+entry.pathname());
                continue;
            }

            uint8[] buffer = null;
            Posix.off_t offset;
            while (archive.read_data_block (out buffer, out offset) == Archive.Result.OK) {
                if (extractor.write_data_block (buffer, offset) != Archive.Result.OK) {
                    break;
                }
            }
        }
        fs_sync();
        error(3);
    }

}

#endif
