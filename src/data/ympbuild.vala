//DOC: ## ympbuild file functions.
//DOC: ymp uses archlinux ympbuild format.

// private variables used by functions
private string ympbuild_srcpath;
private string ympbuild_buildpath;
private string ympbuild_header;


private void ympbuild_init(){
    if(ympbuild_srcpath == null){
        ympbuild_srcpath = "./";
    }
    ympbuild_header = "
    export installdir="+ympbuild_buildpath+"/output
    export DESTDIR=\"$installdir\"
    alias python=python3
    export NOCONFIGURE=1
    export NO_COLOR=1
    export CFLAGS=\"-s -DSULIX -L/lib/sulix "+get_value("build:cflags")+"\"
    export CXXFLAGS=\"-s -DSULIX -L/lib/sulix "+get_value("build:cxxflags")+"\"
    export CC=\""+get_value("build:cc")+"\"
    export LDFLAGS=\""+get_value("build:ldflags")+"\"
    ymp-meson(){
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
    ymp-configure(){
        if [[ -f \"./autogen.sh\" ]] ; then
			NOCONFIGURE=1 ./autogen.sh
		fi
		if [[ -f configure ]] ; then
            ./configure --prefix=/usr \"$@\"
        elif [[ -f meson.build ]] ; then
            ymp-meson build
        elif [[ -f CMakeLists.txt ]] ; then
            mkdir build
            cd build
	        cmake .. -DCMAKE_INSTALL_PREFIX=/usr \"$@\"
	        cd ..
        fi
    }
    ymp-build(){
		if [[ -f configure ]] ; then
            make -j`nproc`
        elif [[ -f meson.build ]] ; then
            ninja -C build
        elif [[ -f CMakeLists.txt ]] ; then
            make -j`nproc`
        fi

    }
    ymp-install(){
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
    ymp_print_metadata(){
        echo \"ymp:\"
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
                echo \"      - ${src}\"
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
    use(){
        [[ \"$1\" == \"31\" ]]
        return $?
    }
    ";
    foreach(string flag in ssplit(get_value("use")," ")){
       if(flag == "" || flag == null){
           continue;
       }
       info("USE flag: "+flag);
       ympbuild_header += "declare -r '"+flag.replace("'","\\'")+"'=31 \n";
    }
    #if debug
    ympbuild_header += "set -x"
    #endif
}
//DOC: `void set_ympbuild_srcpath(string path):`
//DOC: configure ympbuild file directory
public void set_ympbuild_srcpath(string path){
    ympbuild_srcpath = srealpath(path);
    ympbuild_init();
}

//DOC: `void set_ympbuild_srcpath(string path):`
//DOC: configure ympbuild file directory
public void set_ympbuild_buildpath(string path){
    ympbuild_buildpath = srealpath(path);
    ympbuild_init();
}

//DOC: `string get_ympbuild_value(string variable):`
//DOC: get a variable from ympbuild file
public string get_ympbuild_value(string variable){
    if(ympbuild_srcpath == null){
        ympbuild_srcpath = "./";
    }
    return getoutput("bash -c '"+ympbuild_header+" source "+ympbuild_srcpath+"/ympbuild >/dev/null ; echo ${"+variable+"[@]}'").strip();
}

//DOC: `string[] get_ympbuild_array(string variable):`
//DOC: get a array from ympbuild file
public string[] get_ympbuild_array(string variable){
    if(ympbuild_srcpath == null){
        ympbuild_srcpath = "./";
    }
    return ssplit(getoutput("bash -c '"+ympbuild_header+" source "+ympbuild_srcpath+"/ympbuild >/dev/null ; echo ${"+variable+"[@]}'").strip()," ");
}

public bool ympbuild_has_function(string function){
    return 0 == run_silent("bash -c 'source "+ympbuild_srcpath+"/ympbuild ;declare -F "+function+"'");
}

private bool ympbuild_check(){
    return 0 == run("bash -n "+ympbuild_srcpath+"/ympbuild");
}

//DOC: `int run_ympbuild_function(string function):`
//DOC: run a build function from ympbuild file
public int run_ympbuild_function(string function){
    if(function == ""){
        return 0;
    }
    print(colorize("Run action: ",blue)+function);
    if(ympbuild_has_function(function)){
        return run("bash -e -c '"+ympbuild_header+" \n source /etc/profile \n source "+ympbuild_srcpath+"/ympbuild ; set -e ; "+function+"'");
    }else{
        warning("ympbuild function not exists: "+function);
    }
    return 0;
}
public void ymp_process_binaries(){
    foreach(string file in find(ympbuild_buildpath+"/output")){
        if(iself(file)){
            info("Binary process: "+file);
            run_silent("objcopy -R .comment \\
            -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames \\
            -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str \\
            -R .debug_ranges -R .debug_loc '"+file+"' \\;");
        }
    }
}

public string get_ympbuild_metadata(){
    return getoutput ("bash -c '"+ympbuild_header+" source "+ympbuild_srcpath+"/ympbuild >/dev/null ; ymp_print_metadata'");
}
