private string[] quarantine_file_cache_list;
private string[] quarantine_file_conflict_list;
private string[] quarantine_file_broken_list;
//DOC: `bool quarantine_validate_files():`
//DOC: check quarantine file hashes
public bool quarantine_validate_files(){
    // reset lists
    quarantine_file_cache_list = {};
    quarantine_file_conflict_list = {};
    quarantine_file_broken_list = {};
    //get quarantine file store and list
    string rootfs_files = get_storage()+"/quarantine/files/";
    foreach(string files_list in listdir(rootfs_files)){
        // file list format xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx /path/to/file
        // uses sha1sum
        string file_data = readfile(rootfs_files+files_list);
        foreach(string line in ssplit(file_data,"\n")){
            if(line.length > 40){
                // fetch absolute file path
                string path = line[40:];
                path = path.strip();
                string file_path = srealpath(get_storage()+"/quarantine/rootfs/"+path);
                if(!isfile(file_path)){
                    warning("Package file missing: /"+path);
                    quarantine_file_broken_list += file_path;
                    continue;
                }
                // calculate and check sha1sum values
                string sha1sum = line[0:40];
                string calculated_sha1sum = calculate_sha1sum(file_path);
                if(sha1sum != calculated_sha1sum){
                    warning("Broken file detected: /"+path);
                    quarantine_file_broken_list += file_path;
                    continue;
                }
                // check file conflict
                if(file_path in quarantine_file_cache_list){
                    warning("File conflict detected: /"+path);
                    quarantine_file_conflict_list += file_path;
                    continue;
                }
                quarantine_file_cache_list += file_path;
            }
        }
    }
    return true;
}
