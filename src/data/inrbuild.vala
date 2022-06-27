//DOC: ## inrbuild file functions.
//DOC: inary uses archlinux inrbuild format.

// private variables used by functions
private string inrbuild_srcpath;
private string inrbuild_buildpath;
private string inrbuild_header;


private void inrbuild_init(){
    if(inrbuild_srcpath == null){
        inrbuild_srcpath = "./";
    }
    inrbuild_header = "
    export installdir="+inrbuild_buildpath+"/output
    export DESTDIR=\"$installdir\"
    alias python=python3
    export CFLAGS=\"-Dsulin -L/lib/sulin "+get_value("build:cflags")+"\"
    export CXXFLAGS=\"-Dsulin -L/lib/sulin "+get_value("build:cxxflags")+"\"
    export CC=\""+get_value("build:cc")+"\"
    export LDFLAGS=\""+get_value("build:ldflags")+"\"
    inary-meson(){
	  meson setup \\
	    --prefix        /usr \\
	    --libexecdir    libexec \\
	    --libdir        lib \\
	    --sbindir       sbin \\
	    --bindir        bin \\
	    --buildtype     release \\
	    --debug         false \\
	    --auto-features disabled \\
	    --strip         true \\
	    --wrap-mode     nodownload \\
	    --layout        flat \\
	    -D              b_lto=true \\
	    -D              b_pie=true \\
	    -D              b_colorout=never \\
	    -D              b_pgo=true \\
	    -D              b_asneeded=true \\
	    \"$@\"
    }
    _dump_variables(){
        set -o posix ; set  
    }
    inary_print_metadata(){
        echo \"inary:\"
        echo \"  source:\"
        echo \"    name: $name\"
        echo \"    version: $version\"
        echo \"    release: $release\"
        echo \"    description: $description\"
        if [[ \"${makedepends[@]}\" != \"\" ]] ; then
        echo \"    makedepends:\"
        for dep in ${makedepends[@]} ; do
        echo \"      - $dep\"
        done
        fi
        if [[ \"${depends[@]}\" != \"\" ]] ; then
        echo \"    depends:\"
        for dep in ${depends[@]} ; do
        echo \"      - $dep\"
        done
        fi
        if [[ \"${source[@]}\" != \"\" ]] ; then
        echo \"    archive:\"
        for src in ${source[@]} ; do
        echo \"      - $src\"
        done
        fi
        if [[ \"${provides[@]}\" != \"\" ]] ; then
        echo \"    provides:\"
        for pro in ${provides[@]} ; do
        echo \"      - $pro\"
        done
        fi
        if [[ \"${replaces[@]}\" != \"\" ]] ; then
        echo \"    replaces:\"
        for rep in ${replaces[@]} ; do
        echo \"      - $rep\"
        done
        fi
        
    }
    mkdir -p \"$DESTDIR\"
    ";
}
//DOC: `void set_inrbuild_srcpath(string path):`
//DOC: configure inrbuild file directory
public void set_inrbuild_srcpath(string path){
    inrbuild_srcpath = srealpath(path);
    inrbuild_init();
}

//DOC: `void set_inrbuild_srcpath(string path):`
//DOC: configure inrbuild file directory
public void set_inrbuild_buildpath(string path){
    inrbuild_buildpath = srealpath(path);
    inrbuild_init();
}

//DOC: `string get_inrbuild_value(string variable):`
//DOC: get a variable from inrbuild file
public string get_inrbuild_value(string variable){
    if(inrbuild_srcpath == null){
        inrbuild_srcpath = "./";
    }
    return getoutput("bash -c '"+inrbuild_header+" source "+inrbuild_srcpath+"/INRBUILD ; echo ${"+variable+"[@]}'").strip();
}

//DOC: `string[] get_inrbuild_array(string variable):`
//DOC: get a array from inrbuild file
public string[] get_inrbuild_array(string variable){
    if(inrbuild_srcpath == null){
        inrbuild_srcpath = "./";
    }
    return ssplit(getoutput("bash -c '"+inrbuild_header+" source "+inrbuild_srcpath+"/INRBUILD ; echo ${"+variable+"[@]}'").strip()," ");
}

public bool inrbuild_has_function(string function){
    return 0 == run_silent("bash -c 'source "+inrbuild_srcpath+"/INRBUILD ;declare -F "+function+"'");
}

//DOC: `int run_inrbuild_function(string function):`
//DOC: run a build function from inrbuild file
public int run_inrbuild_function(string function){
    if(function == ""){
        return 0;
    }
    print(colorize("Run action: ",blue)+function);
    if(inrbuild_has_function(function)){
        return run("bash -e -c '"+inrbuild_header+" source "+inrbuild_srcpath+"/INRBUILD ; "+function+"'");
    }
    return 0;
}

public string get_inrbuild_metadata(){
    return getoutput ("bash -c '"+inrbuild_header+" source "+inrbuild_srcpath+"/INRBUILD >/dev/null ; inary_print_metadata'");
}
