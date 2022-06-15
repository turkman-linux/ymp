private string[] quarantine_file_cache_list;
private string[] quarantine_file_conflict_list;
//DOC: `bool quarantine_validate_files():`
//DOC: check quarantine file hashes
public bool quarantine_validate_files(){
    // reset lists
    quarantine_file_cache_list = {};
    quarantine_file_conflict_list = {};
    //get quarantine file store and list
    string rootfs_files = get_storage()+"/quarantine/files/";
    foreach(string files_list in listdir(rootfs_files)){
        // file list format xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx /path/to/file
        // uses sha1sum
        string file_data = readfile(rootfs_files+files_list);
        foreach(string line in ssplit(file_data,"\n")){
            if(line.length > 40){
                // fetch hash and absolute file path
                string sha1sum_hash = line[0:40];
                string path = line[40:];
                string file_path = srealpath(get_storage()+"/quarantine/rootfs/"+path.strip());
                if(file_path in quarantine_file_cache_list){
                    quarantine_file_conflict_list += file_path;
                    warning("File conflict detected: /"+path.strip());
                }else{
                    quarantine_file_cache_list += file_path;
                }
            }
        }
    }
    return true;
}

