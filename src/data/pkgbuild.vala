//DOC: # PKGBUILD file functions.
//DOC: inary uses archlinux pkgbuild format.

// private variables used by functions
private string pkgbuild_srcpath;
private string pkgbuild_pkgdir;
private string pkgbuild_header;


private void pkgbuild_init(){
    if(pkgbuild_srcpath == null){
        pkgbuild_srcpath = "./";
    }
    pkgbuild_header = "
    pkgdir="+pkgbuild_pkgdir+"/output
    alias python=python3
    alias msg2=echo
    arch-meson(){
	exec meson setup \\
	  --prefix        /usr \\
	  --libexecdir    lib \\
	  --sbindir       bin \\
	  --buildtype     plain \\
	  --auto-features enabled \\
	  --wrap-mode     nodownload \\
	  -D              b_lto=true \\
	  -D              b_pie=true \\
	  \"$@\"
    }
    _dump_variables(){
        set -o posix ; set  
    }
    mkdir -p $pkgdir
    ";
}
//DOC: `void set_pkgbuild_srcpath(string path):`
//DOC: configure pkgbuild file directory
public void set_pkgbuild_srcpath(string path){
    pkgbuild_srcpath = srealpath(path);
    pkgbuild_init();
}

//DOC: `void set_pkgbuild_srcpath(string path):`
//DOC: configure pkgbuild file directory
public void set_pkgbuild_buildpath(string path){
    pkgbuild_pkgdir = srealpath(path);
    pkgbuild_init();
}

//DOC: `string get_pkgbuild_value(string variable):`
//DOC: get a variable from pkgbuild file
public string get_pkgbuild_value(string variable){
    if(pkgbuild_srcpath == null){
        pkgbuild_srcpath = "./";
    }
    return getoutput("bash -c '"+pkgbuild_header+" source "+pkgbuild_srcpath+"/PKGBUILD ; echo ${"+variable+"[@]}'").strip();
}

//DOC: `string[] get_pkgbuild_array(string variable):`
//DOC: get a array from pkgbuild file
public string[] get_pkgbuild_array(string variable){
    if(pkgbuild_srcpath == null){
        pkgbuild_srcpath = "./";
    }
    return ssplit(getoutput("bash -c '"+pkgbuild_header+" source "+pkgbuild_srcpath+"/PKGBUILD ; echo ${"+variable+"[@]}'").strip()," ");
}

//DOC: `int run_pkgbuild_function(string function):`
//DOC: run a build function from pkgbuild file
public int run_pkgbuild_function(string function){
    return run("bash -c '"+pkgbuild_header+" source "+pkgbuild_srcpath+"/PKGBUILD ;declare -f -F "+function+" && "+function+" || true'");
}
