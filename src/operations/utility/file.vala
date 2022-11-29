public int file_main(string[] args){
    if(get_bool("remove")){
        return remove_file_main(args);
    }else if (get_bool("copy")){
        return copy_file_main(args);
    }else if (get_bool("move")){
        return copy_file_main(args);
    }else if (get_bool("extract")){
        return extract_main(args);
    }
    return 0;
}

public int remove_file_main(string[] args){
    foreach(string arg in args){
        remove_all(arg);
    }
    return 0;
}

public int copy_file_main(string[] args){
    if(args.length < 2){
        error_add("Source or Target not defined.");
        error(1);
    }
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

public int move_file_main(string[] args){
    if(args.length < 2){
        error_add("Source or Target not defined.");
        error(1);
    }
    string src = srealpath(args[0]);
    string desc = srealpath(args[1]);
    if(isfile(src)|| issymlink(src)){
        if(isdir(desc)){
            desc += "/"+sbasename(src);
        }
        move_file(src,desc);
    }else{
        foreach(string file in find(src)){
            string target=file[src.length:];
            move_file(file,desc+"/"+target);
        }
    }
    return 0;
}

void file_init(){
    var h = new helpmsg();
    h.name = "file";
    h.minargs=1;
    h.description = "Copy / Move / Remove files or directories";
    h.add_parameter("--remove","remove file or directories");
    h.add_parameter("--copy","copy file or directories");
    h.add_parameter("--move","move file or directories");
    h.add_parameter("--extract","extract archive file (same as extract operation)");
    add_operation(file_main,{"f", "file"},h);
}
