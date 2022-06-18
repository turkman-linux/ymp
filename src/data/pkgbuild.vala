//DOC: ## PKGBUILD file functions.
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
    inary_print_metadata(){
        echo \"inary:\"
        echo \"  source:\"
        echo \"    name: $pkgname\"
        echo \"    version: $pkgver\"
        echo \"    release: $pkgrel\"
        echo \"    description: $pkgdesc\"
        echo \"    makedepends:\"
        for dep in ${makedepends[@]} ; do
        echo \"      - $dep\"
        done
        echo \"    depends:\"
        for dep in ${depends[@]} ; do
        echo \"      - $dep\"
        done
        echo \"    archive:\"
        for src in ${source[@]} ; do
        echo \"      - $src\"
        done
        echo \"    provides:\"
        for pro in ${provides[@]} ; do
        echo \"      - $pro\"
        done
        echo \"    replaces:\"
        for rep in ${replaces[@]} ; do
        echo \"      - $rep\"
        done
        
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
    info(colorize("Run action: ",blue)+function);
    return run("bash -c '"+pkgbuild_header+" source "+pkgbuild_srcpath+"/PKGBUILD ;declare -f -F "+function+" && "+function+" || true'");
}

public string get_pkgbuild_metadata(){
return getoutput ("bash -c '"+pkgbuild_header+" source "+pkgbuild_srcpath+"/PKGBUILD >/dev/null ; inary_print_metadata'");
}
