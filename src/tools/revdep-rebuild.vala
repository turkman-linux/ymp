int main(string[] args){
    inary_init(args);
    set_env("LANG","C");
    set_env("LC_ALL","C");
    string[] paths = {
        "/lib","/lib64","/usr/lib","/usr/lib64",
        "/lib32","/usr/lib32","/libx32","/usr/libx32",
    };
    foreach(string path in paths){
        string libraries = getoutput("find "+path+" -type f -iname \"*.so.*\"");
        check(libraries);
    }
    paths = {"/bin","/sbin","/usr/bin","/usr/sbin",};
    foreach(string path in paths){
        string binaries = getoutput("find "+path+" -type f");
        check(binaries);
    }
    return 0;
}

public void check(string libraries){
    foreach(string library in libraries.split("\n")){
        foreach(string line in getoutput("ldd "+library).split("\n")){
            if(endswith(line,"not found")){
                print(colorize(library,red) +" => "+ line[1:line.length-13]);
            }
        }

    }
}
