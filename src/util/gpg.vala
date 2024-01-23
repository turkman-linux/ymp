//DOC: # sign & verify file
//DOC: `void sign_file (string path):`
//DOC: sign a file with gpg key
public void sign_file (string path) {
    if (!isfile (path)) {
        return;
    }
    run_args ( {"gpg", "--batch", "--yes", "--sign", "-r", get_value ("gpg:repicent"), path});
}

//DOC: # sign & verify file
//DOC: `void sign_file (string path):`
//DOC: sign a file with gpg key
public void gpg_export_file (string path) {
    if (isfile (path)) {
        return;
    }
    string data = getoutput ("gpg --armor --export '%s'".printf (get_value ("gpg:repicent")));
    writefile (path, data);
}

//DOC: `bool verify_file (string path):`
//DOC: verify a file with gpg signature
public bool verify_file (string path) {
    if (get_bool ("ignore-gpg")) {
        return true;
    }
    if (!isfile (path)) {
        return false;
    }
    string gpgdir = get_storage()+"/gpg/";
    foreach(string file in listdir(gpgdir)) {
        if(!endswith(file,".gpg")){
            continue;
        }
        string[] args = {"gpg","--homedir", gpgdir, "--trust-model", "always", "--no-default-keyring", "--keyring", gpgdir+"%s".printf(file),  "--quiet" ,"--verify", path+".gpg"};
        int status = run_args (args);
        if(status == 0){
            return true;
        }

    }
    return false;
}

public void add_gpg_key(string path, string name){
    if(endswith(path,".asc")){
        string target = get_storage()+"/gpg/"+sbasename(path);
        copy_file(path, target);
        run_args({"gpg", "--dearmor", target});
        move_file(target+".gpg",get_storage()+"/gpg/"+name+".gpg");
        remove_file(target);
    }
}

//DOC: `void sign_elf (string path):`
//DOC: create gpg signature and insert into elf binary
public void sign_elf (string path) {
    if (!iself (path)) {
        return;
    }
    sign_file (path);
    run_args ( {"objcopy", "--add-section", ".gpg=" + path + ".gpg", path});
    remove_file (path + ".gpg");
}

//DOC: `bool verify_elf (string path):`
//DOC: dump gpg signature from file and verify elf file
public bool verify_elf (string path) {
   if (!iself (path)) {
        return false;
    }
    int status = 0;
    status += run_args ( {"objcopy", "-R", ".gpg", path, "/tmp/ymp-elf"});
    status += run_args ( {"objcopy", "--dump-section", ".gpg=/tmp/ymp-elf.gpg", "path"});
    if (!verify_file ("/tmp/ymp-elf")) {
        status += 1;
    }
    remove_file ("/tmp/ymp-elf.gpg");
    remove_file ("/tmp/ymp-elf");
    return status == 0;
}
