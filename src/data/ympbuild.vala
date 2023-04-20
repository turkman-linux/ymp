//DOC: ## ympbuild file functions.
//DOC: ymp uses ympbuild format.

// private variables used by functions
private string ympbuild_srcpath;
private string ympbuild_buildpath;
private string ympbuild_header;


private void ympbuild_init(){
    if(ympbuild_srcpath == null){
        ympbuild_srcpath = "./";
    }
    string jobs = get_value("build:jobs");
    if(jobs == "0"){
        jobs = "`nproc`";
    }
    ympbuild_header = "
    export PATH=\":/usr/sbin:/usr/bin:/bin:/sbin\"

    declare -r installdir=\""+ympbuild_buildpath+"/output\"
    declare -r jobs=\"-j"+jobs+"\"
    export HOME=\""+ympbuild_buildpath+"\"
    export DESTDIR=\"$installdir\"
    declare -r YMPVER=\""+VERSION+"\"
    export NOCONFIGURE=1
    export NO_COLOR=1
    export VERBOSE=1
    export FORCE_UNSAFE_CONFIGURE=1
    export V=1
    export CFLAGS=\"-s -DTURKMAN -L"+DISTRODIR+" "+get_value("build:cflags")+"\"
    export CXXFLAGS=\"-s -DTURKMAN -L"+DISTRODIR+" "+get_value("build:cxxflags")+"\"
    export CC=\""+get_value("build:cc")+"\"
    export LDFLAGS=\""+get_value("build:ldflags")+"\"

    function _dump_variables(){
        set -o posix ; set  
    }
    function ymp_print_metadata(){
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
        if [[ \"${arch[@]}\" != \"\" ]] ; then
            echo \"    arch:\"
            for dep in ${arch[@]} ; do
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
        if [[ \"${group[@]}\" != \"\" ]] ; then
            echo \"    group:\"
            for grp in ${group[@]} ; do
                echo \"      - ${grp}\"
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
        if [[ \"${uses[@]}\" != \"\" || \"${uses_extra[@]}\" != \"\" ]] ; then
            echo \"    use-flags:\"
            for use in ${uses[@]} ; do
                echo \"      - $use\"
            done
            for flag in ${uses[@]} ${uses_extra[@]} ; do
                flag_dep=\"${flag}_depends\"
                if [[ \"$(eval echo \\${${flag_dep}[@]})\" != \"\" ]] ; then
                    echo \"    ${flag}-depends:\"
                    for dep in $(eval echo \\${${flag_dep}[@]}) ; do
                        echo \"      - $dep\"
                    done
                fi
            done
        fi
    }
    function use(){
        if ! echo ${uses[@]} ${uses_extra[@]} `uname -m` all extra | grep \"$1\" >/dev/null; then
            echo \"Use flag \\\"$1\\\" is unknown!\"
            exit 1
        fi
        if [[ \"${use_all}\" == \"31\" ]] ; then
            if echo ${uses[@]} | grep \"$1\" >/dev/null; then
                return 0
            fi
        fi
        if [[ \"${use_extra}\" == \"31\" ]] ; then
            if echo ${uses_extra[@]} | grep \"$1\" >/dev/null; then
                return 0
            fi
        fi
        for use in ${uses[@]} ${uses_extra[@]}; do
            if [[ \"${use}\" == \"$1\" ]] ; then
                flag=\"use_$1\"
                [[ \"${!flag}\" == \"31\" ]]
                return $?
            fi
        done
    }
    function use_opt(){
        if use \"$1\" ; then
            echo $2
        else
            echo $3
        fi
    }
    function eapply(){
        for aa in $* ; do
            patch -Np1 \"$aa\"
        done
    }
    ";
    var use_flags = new array();
    string[] flags = ssplit(get_value("use")," ");
    string name = get_ympbuild_value("name");
    string package_use = get_config("package.use",name);
    if(package_use.length > 0){
        flags = ssplit(package_use," ");
    }
    foreach(string flag in flags){
       use_flags.add(flag);
       ympbuild_header += "declare -r use_'"+flag.replace("'","\\'")+"'=31 \n";

    }
    ympbuild_header += "declare -r use_"+getArch()+"=31 \n";
    print(colorize(_("USE flag: %s"),green).printf(join(" ",use_flags.get())));
}
//DOC: `void set_ympbuild_srcpath(string path):`
//DOC: configure ympbuild file directory
public void set_ympbuild_srcpath(string path){
    debug(_("Set ympbuild src path : %s").printf(path));
    ympbuild_srcpath = srealpath(path);
}

//DOC: `void set_ympbuild_srcpath(string path):`
//DOC: configure ympbuild file directory
public void set_ympbuild_buildpath(string path){
    ympbuild_buildpath = srealpath(path);
    create_dir(ympbuild_buildpath);
    debug(_("Set ympbuild build path : %s").printf(ympbuild_buildpath));
    ympbuild_init();
}

//DOC: `string get_ympbuild_value(string variable):`
//DOC: get a variable from ympbuild file
public string get_ympbuild_value(string variable){
    if(ympbuild_srcpath == null){
        ympbuild_srcpath = "./";
    }
    return getoutput("env -i bash -c 'source "+ympbuild_srcpath+"/ympbuild >/dev/null ; echo ${"+variable+"[@]}'").strip();
}

//DOC: `string[] get_ympbuild_array(string variable):`
//DOC: get a array from ympbuild file
public string[] get_ympbuild_array(string variable){
    if(ympbuild_srcpath == null){
        ympbuild_srcpath = "./";
    }
    return ssplit(getoutput("env -i bash -c 'source "+ympbuild_srcpath+"/ympbuild >/dev/null ; echo ${"+variable+"[@]}'").strip()," ");
}

//DOC: `bool ympbuild_has_function(string function):`
//DOC: check ympbuild file has function
public bool ympbuild_has_function(string function){

    return 0 == run(
        "bash -c 'set +e ; source %s/ympbuild &>/dev/null; set -e; declare -F %s'".printf(
            ympbuild_srcpath,
            function
        )
    );
}

private bool ympbuild_check(){
    info(_("Check ympbuild: %s/ympbuild").printf(ympbuild_srcpath));
    return 0 == run("bash -n "+ympbuild_srcpath+"/ympbuild");
}

//DOC: `int run_ympbuild_function(string function):`
//DOC: run a build function from ympbuild file
public int run_ympbuild_function(string function){
    if(function == ""){
        return 0;
    }
    set_terminal_title(_("Run action (%s) %s => %s").printf(
        sbasename(ympbuild_buildpath),
        get_ympbuild_value("name"),
        function));
    if(ympbuild_has_function(function)){
    
        string cmd = "bash -c '%s \n set +e ; source %s/ympbuild ; export ACTION=%s ; set -e ; %s'".printf(
            ympbuild_header,
            ympbuild_srcpath,
            function,
            function
        );
        if(get_bool("quiet")){
            return run_silent(cmd);
        }else{
            return run(cmd);
        }
    }else{
        warning(_("ympbuild function not exists: %s").printf(function));
    }
    return 0;
}
public void ymp_process_binaries(){
    string[] garbage_dirs = {STORAGEDIR, "/tmp", "/run", "/dev", "/data", "/home"};
    foreach(string dir in garbage_dirs){
        if(isdir(ympbuild_buildpath+"/output/"+dir)){
            remove_all(ympbuild_buildpath+"/output/"+dir);
        }
    }
    if (get_ympbuild_value("dontstrip") == ""){
        foreach(string file in find(ympbuild_buildpath+"/output")){
            if(endswith(file,".a") || endswith(file,".o")){
                // skip static library
                info(_("Binary process skip for: %s").printf(file));
                continue;
            }
            if(iself(file)){
                print(colorize(_("Binary process: %s"),magenta).printf(file[(ympbuild_buildpath+"/output").length:]));
                run("objcopy -R .comment \\
                -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames \\
                -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str \\
                -R .debug_ranges -R .debug_loc '"+file+"'");
                run("strip '"+file+"'");
            }
        }
    }
    foreach(string file in find(ympbuild_buildpath+"/lib64")){
        if(iself(file) && !is64bit(file)){
            warning(_("File is not 64bit: %s").printf(file));
        }
    }
    foreach(string file in find(ympbuild_buildpath+"/usr/lib64")){
        if(iself(file) && !is64bit(file)){
            warning(_("File is not 64bit: %s").printf(file));
        }
    }
    foreach(string file in find(ympbuild_buildpath+"/lib32")){
        if(iself(file) && is64bit(file)){
            warning(_("File is not 32bit: %s").printf(file));
        }
    }
    foreach(string file in find(ympbuild_buildpath+"/usr/lib32")){
        if(iself(file) && is64bit(file)){
            warning(_("File is not 32bit: %s").printf(file));
        }
    }
    if(isfile(ympbuild_buildpath+"/output/usr/share/info/dir")){
        remove_file(ympbuild_buildpath+"/output/usr/share/info/dir");
    }
    foreach(string path in find(ympbuild_buildpath+"/output")){
        if(endswith(path,".pyc")){
            remove_file(path);
        }
    }
}

//DOC: `string get_ympbuild_metadata():`
//DOC: generate metadata.yaml content and return as string
public string get_ympbuild_metadata(){
    return getoutput ("env -i bash -c '"+ympbuild_header+" source "+ympbuild_srcpath+"/ympbuild &>/dev/null ; ymp_print_metadata'");
}
