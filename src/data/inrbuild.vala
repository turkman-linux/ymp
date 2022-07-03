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
    source /etc/profile
    export installdir="+inrbuild_buildpath+"/output
    export DESTDIR=\"$installdir\"
    alias python=python3
    export NOCONFIGURE=1
    export NO_COLOR=1
    export CFLAGS=\"-s -Dsulin -L/lib/sulin "+get_value("build:cflags")+"\"
    export CXXFLAGS=\"-s -Dsulin -L/lib/sulin "+get_value("build:cxxflags")+"\"
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
    inary-configure(){
        if [[ -f \"./autogen.sh\" ]] ; then
			NOCONFIGURE=1 ./autogen.sh
		fi
		if [[ -f configure ]] ; then
            ./configure --prefix=/usr \"$@\"
        elif [[ -f meson.build ]] ; then
            inary-meson build
        elif [[ -f CMakeLists.txt ]] ; then
            mkdir build
            cd build
	        cmake .. -DCMAKE_INSTALL_PREFIX=/usr \"$@\"
	        cd ..
        fi
    }
    inary-build(){
		if [[ -f configure ]] ; then
            make -j`nproc`
        elif [[ -f meson.build ]] ; then
            ninja -C build
        elif [[ -f CMakeLists.txt ]] ; then
            make -j`nproc`
        fi

    }
    inary-install(){
    	if [[ -f configure ]] ; then
            make -j`nproc` install DESTDIR=$DESTDIR
        elif [[ -f meson.build ]] ; then
            ninja -C build install
        elif [[ -f CMakeLists.txt ]] ; then
            make -j`nproc` install DESTDIR=$DESTDIR
        fi
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
    foreach(string flag in ssplit(get_value("USE")," ")){
       if(flag == "" || flag == null){
           continue;
       }
       inrbuild_header += "declare -r '"+flag.replace("'","\\'")+"'=31 \n";
    }
    #if debug
    inrbuild_header += "set -x"
    #endif
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
    }else{
        warning("INRBUILD function not exists: "+function);
    }
    return 0;
}
public void inary_process_binaries(){
    foreach(string file in find(inrbuild_buildpath+"/output")){
        if(iself(file)){
            run_silent("objcopy -R .comment \\
            -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames \\
            -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str \\
            -R .debug_ranges -R .debug_loc '"+file+"' \\;");
        }
    }
}

public string get_inrbuild_metadata(){
    return getoutput ("bash -c '"+inrbuild_header+" source "+inrbuild_srcpath+"/INRBUILD >/dev/null ; inary_print_metadata'");
}
