public int copy_main(string[] args){
    string src = srealpath(args[0]);
    string desc = srealpath(args[1]);
    if(isfile(src)|| issymlink(src)){
        if(isdir(desc)){
            desc += "/"+sbasename(src);
        }
        copy_file(src,desc);
    }else{
        foreach(string file in find(src)){
            string target=file[src.length:];
            copy_file(file,desc+"/"+target);
        }
    }
    return 0;
}
void copy_init(){
    var h = new helpmsg();
    h.name = "copy";
    h.minargs=2;
    h.description = "Copy file";
    add_operation(copy_main,{"cp", "copy"},h);
}
