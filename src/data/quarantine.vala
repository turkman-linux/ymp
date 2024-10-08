
private static array quarantine_file_cache_list;
private static array quarantine_file_conflict_list;
private static array quarantine_file_replaces_list;
private static array quarantine_file_broken_list;

#define rootfs_files get_storage () + "/quarantine/files/"
#define rootfs_links get_storage () + "/quarantine/links/"
private static string[] restricted_list;

//DOC: `void quarantine_reset ():`
//DOC: remove quarantine directories and create new ones
public void quarantine_reset () {
  remove_all (get_storage () + "/quarantine/");
  create_dir (get_storage () + "/quarantine/rootfs");
  create_dir (get_storage () + "/quarantine/tmp");
  create_dir (get_storage () + "/quarantine/files");
  create_dir (get_storage () + "/quarantine/links");
  create_dir (get_storage () + "/quarantine/metadata");
}

private string[] get_quarantine_conflict_packages (string path, bool symlink) {
    var ret = new array ();
    if (symlink) {
        foreach (string links_list in listdir (rootfs_links)) {
            string link_data = readfile_cached (rootfs_links + links_list);
            foreach (string line in ssplit (link_data, "\n")) {
                if (" " in line) {
                    string fpath = ssplit (line, " ")[0];
                    if (path == fpath) {
                        ret.add (links_list);
                    }
                }
            }
        }
    }else {
        foreach (string files_list in listdir (rootfs_files)) {
            string file_data = readfile_cached (rootfs_files + files_list);
            foreach (string line in ssplit (file_data, "\n")) {
                if (line.length > 41) {
                    string fpath = line[41:];
                    if (path == fpath) {
                        ret.add (files_list);
                    }
                }
            }
        }
    }
    return ret.get ();
}

//DOC: `bool quarantine_validate ():`
//DOC: check quarantine file hashes
public bool quarantine_validate () {
    if (get_bool ("ignore-quarantine")) {
        warning (_ ("Quarantine validation disabled."));
        return true;
    }
    // reset lists
    quarantine_file_cache_list = new array ();
    quarantine_file_conflict_list = new array ();
    quarantine_file_broken_list = new array ();
    quarantine_file_replaces_list = new array ();
    // get quarantine file store and list
    restricted_list = ssplit (readfile (get_storage () + "/restricted.list"), "\n");
    // add package db into restricted_list
    restricted_list += STORAGEDIR;
    jobs j = new jobs();
    foreach (string files_list in listdir (rootfs_files)) {
        j.add((void*)quarantine_validate_file, strdup(files_list));
    }
    foreach (string links_list in listdir (rootfs_links)) {
        j.add((void*)quarantine_validate_links, strdup(links_list));
    }
    j.run();
    foreach (string* path in quarantine_file_replaces_list.get ()) {
        quarantine_file_conflict_list.remove (path);
    }
    if (quarantine_file_conflict_list.length () > 0 || quarantine_file_broken_list.length () > 0) {
        return false;
    }
    return true;
}

private static void quarantine_validate_file(string* files_list){
    string file_data = readfile_raw (rootfs_files + files_list);
    // file list format xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx /path/to/file
    // uses sha1sum
	print (colorize (_ ("Validating:"), yellow) + " " + files_list + "(files)");
    foreach (string line in ssplit (file_data, "\n")) {
        if (line.length > 41) {
            // fetch absolute file path
            string path = line[41:];
            path = path.strip ();
            string file_path = get_storage () + "/quarantine/rootfs/" + path;
            // check file conflict
            info (_ ("Validating: %s").printf (path));
            if (!quarantine_file_conflict_list.has (file_path) && quarantine_file_cache_list.has (file_path)) {
                string[] conflict_packages = get_quarantine_conflict_packages (path, false);
                error_add (_ ("File conflict detected: /%s (%s)").printf (path, join (" ", conflict_packages)));
                quarantine_file_conflict_list.add (file_path);
                continue;
            }
            quarantine_file_cache_list.add (file_path);
            if (!isfile (file_path)) {
                error_add (_ ("Package file is missing: /%s (%s)").printf (path, files_list));
                quarantine_file_broken_list.add (file_path);
                continue;
            }
            foreach (string restricted in restricted_list) {
                if (restricted.length > 0 && Regex.match_simple (restricted, path)) {
                    error_add (_ ("File in restricted path is not allowed: /%s (%s)").printf (path, files_list));
                    quarantine_file_broken_list.add (file_path);
                    continue;
                }
            }
            // calculate and check sha1sum values
            string sha1sum = line[0:40];
            string calculated_sha1sum = calculate_sha1sum (file_path);
            if (sha1sum != calculated_sha1sum) {
                error_add (_ ("Broken file detected: /%s (%s)").printf (path, files_list));
                quarantine_file_broken_list.add (file_path);
                continue;
            }
        }
    }
}

private static void quarantine_validate_links(string* links_list){
    print (colorize (_ ("Validating:"), yellow) + " " + links_list + "(links)");
    string link_data = readfile_raw (rootfs_links + links_list);
    foreach (string line in ssplit (link_data, "\n")) {
        if (" " in line) {
            string path = ssplit (line, " ")[0];
            string target = ssplit (line, " ")[1];
            string link_path = get_storage () + "/quarantine/rootfs/" + path;
            // check broken symlink
            info (_ ("Validating: %s").printf (path));
            string link_target = sreadlink (link_path);
            if (target != link_target) {
                error_add (_ ("Broken symlink detected: /%s (%s)").printf (path, links_list));
                quarantine_file_broken_list.add (link_path);
                continue;
            }
            // check file conflict
            if (!quarantine_file_conflict_list.has (link_path) && quarantine_file_cache_list.has (link_path)) {
                string[] conflict_packages = get_quarantine_conflict_packages (path, true);
                error_add (_ ("Symlink conflict detected: /%s (%s)").printf (path, join (" ", conflict_packages)));
                quarantine_file_conflict_list.add (link_path);
                continue;
            }
            if (!issymlink (link_path)) {
                error_add (_ ("Package symlink is missing: /%s (%s)").printf (path, links_list));
                quarantine_file_broken_list.add (link_path);
                continue;
            }
            foreach (string restricted in restricted_list) {
                if (restricted.length > 0 && Regex.match_simple (restricted, path)) {
                    error_add (_ ("Symlink in restricted path is not allowed: /%s (%s)").printf (path, links_list));
                    quarantine_file_broken_list.add (link_path);
                    continue;
                }
            }
            quarantine_file_cache_list.add (link_path);
        }
    }
}

//DOC: `void quarantine_install ():`
//DOC: install quarantine files to rootfs
public void quarantine_install () {
    print (colorize (_ ("Quarantine installation"), yellow));
    string rootfs = srealpath (get_storage () + "/quarantine/rootfs/");
    string files = srealpath (get_storage () + "/quarantine/files/");
    string links = srealpath (get_storage () + "/quarantine/links/");
    string metadata = srealpath (get_storage () + "/quarantine/metadata/");
    foreach (string fname in find (rootfs)) {
        string ftarget = get_destdir () + fname[rootfs.length:];
        string fdir = sdirname (ftarget);
        debug (_ ("Installing: %s => %s").printf (fname, ftarget));
        create_dir (fdir);
        GLib.FileUtils.chmod (fdir, 0755);
        if (isfile (fname)) {
            move_file (fname, ftarget);
            GLib.FileUtils.chmod (ftarget, 0755);
            if (is_root ()) {
                chown (ftarget, 0, 0);
            }
        }
    }
    fs_sync ();
    foreach (string fname in listdir (files)) {
        if (isfile (get_storage () + "/files/" + fname)) {
            remove_file (get_storage () + "/files/" + fname);
        }
        move_file (files + "/" + fname, get_storage () + "/files/" + fname);
    }
    fs_sync ();
    foreach (string fname in listdir (links)) {
        if (isfile (get_storage () + "/links/" + fname)) {
            remove_file (get_storage () + "/links/" + fname);
        }
        move_file (links + "/" + fname, get_storage () + "/links/" + fname);
    }
    fs_sync ();
    foreach (string fname in listdir (metadata)) {
        if (isfile (get_storage () + "/metadata/" + fname)) {
            remove_file (get_storage () + "/metadata/" + fname);
        }
        move_file (metadata + "/" + fname, get_storage () + "/metadata/" + fname);
    }
    fs_sync ();
}

private void quarantine_import_from_path (string fpath) {
    print (colorize (_ ("Quarantine import"), yellow));
    string rootfs = srealpath (get_storage () + "/quarantine/rootfs/");
    string files = srealpath (get_storage () + "/quarantine/files/");
    string links = srealpath (get_storage () + "/quarantine/links/");
    string metadata = srealpath (get_storage () + "/quarantine/metadata/");
    package p = new package ();
    p.load (fpath + "/metadata.yaml");
    move_file (fpath + "/metadata.yaml", metadata + "/" + p.name + ".yaml");
    move_file (fpath + "/files", files + "/" + p.name);
    move_file (fpath + "/links", links + "/" + p.name);
    string path = fpath + "/output/";
    foreach (string fname in find (path)) {
        string ftarget = fname[path.length:];
        if (isfile (fname)) {
            create_dir (rootfs + sdirname (ftarget));
            move_file (fname, rootfs + ftarget);
        }
    }
    error (2);
    fs_sync ();
}
