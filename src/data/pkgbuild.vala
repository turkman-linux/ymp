//DOC: # PKGBUILD file functions.
//DOC: inary uses archlinux pkgbuild format.

// private variables used by functions
private string pkgbuild_path;

//DOC: `void set_pkgbuild_path(string path):`
//DOC: configure pkgbuild file directory
public void set_pkgbuild_path(string path){
    pkgbuild_path = path;
}

//DOC: `string get_pkgbuild_value(string variable):`
//DOC: get a variable from pkgbuild file
public string get_pkgbuild_value(string variable){
    if(pkgbuild_path == null){
        pkgbuild_path = "./";
    }
    return getoutput("bash -c 'source "+pkgbuild_path+"/PKGBUILD ; echo ${"+variable+"[@]}'").strip();
}

//DOC: `string[] get_pkgbuild_array(string variable):`
//DOC: get a array from pkgbuild file
public string[] get_pkgbuild_array(string variable){
    if(pkgbuild_path == null){
        pkgbuild_path = "./";
    }
    return ssplit(getoutput("bash -c 'source "+pkgbuild_path+"/PKGBUILD ; echo ${"+variable+"[@]}'").strip()," ");
}

//DOC: `int run_pkgbuild_function(string function):`
//DOC: run a build function from pkgbuild file
public int run_pkgbuild_function(string function){
    return run("bash -c 'source PKGBUILD ;"+function);
}
