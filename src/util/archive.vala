public class archive {

    Archive.Read archive;
    private string archive_path;

    public void load(string path){
        archive_path = path;
    }
    private void load_archive(string path){
        archive = new Archive.Read();
        archive.support_filter_all ();
        archive.support_format_all ();
        if (archive.open_filename (archive_path, 10240) != Archive.Result.OK) {
            error ("Error: %s (%d)", archive.error_string (), archive.errno ());
        }
    }
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
            if (extractor.write_header (entry) != Archive.Result.OK) {
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
    }

    public void extract_all(){
        foreach (string path in list_files()){
            stdout.printf(path+"\n");
            extract(path);
        }
    }

}
