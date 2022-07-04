//DOC: # sign & verify file
//DOC: `void sign_file(string path):`
//DOC: sign a file with gpg key
public void sign_file(string path){
    if(!isfile(path)){
        return;
    }
    run_args({"gpg", "--detach-sign","-r", get_value("gpg:repicent"), path});
}
//DOC: `bool verify_file(string path):`
//DOC: verify a file with gpg signature
public bool verify_file(string path){
    if(!isfile(path)){
        return false;
    }
    return 0 == run_args({"gpg","--verify", path+".sig", path});
}

//DOC: `void sign_elf(string path):`
//DOC: create gpg signature and insert into elf binary
public void sign_elf(string path){
    if(!iself(path)){
        return;
    }
    sign_file(path);
    run_args({"objcopy", "--add-section", ".gpg="+path+".sig", path});
    remove_file(path+".sig");
}

//DOC: `bool verify_elf(string path):`
//DOC: dump gpg signature from file and verify elf file
public bool verify_elf(string path){
   if(!iself(path)){
        return false;
    }
    int status = 0;
    status += run_args({"objcopy", "-R", ".gpg", path, "/tmp/inary-elf"});
    status += run_args({"objcopy", "--dump-section", ".gpg=/tmp/inary-elf.sig", "path"});
    if(!verify_file("/tmp/inary-elf")){
        status += 1;
    }
    remove_file("/tmp/inary-elf.sig");
    remove_file("/tmp/inary-elf");
    return status == 0;
}
