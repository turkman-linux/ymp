//DOC: # sign & verify file
//DOC: `void sign_file(string path):`;
//DOC: sign a file with gpg key;
public void sign_file(string path){
    if(!isfile(path)){
        return;
    }
    run_silent("gpg --detach-sign -r '"+get_value("gpg:repicent")+"' '"+path+"'");
}
//DOC: `bool verify_file(string path):`;
//DOC: verify a file with gpg signature;
public bool verify_file(string path){
    if(!isfile(path)){
        return false;
    }
    return 0 == run_silent("gpg --verify '"+path+".sig' '"+path+"'");
}
