public int file_main (string[] args) {
    if (get_bool ("remove")) {
        return remove_file_main (args);
    }else if  (get_bool ("copy")) {
        return copy_file_main (args);
    }else if  (get_bool ("move")) {
        return copy_file_main (args);
    }else if  (get_bool ("extract")) {
        return extract_main (args);
    }
    return 0;
}

public int remove_file_main (string[] args) {
    foreach (string arg in args) {
        remove_all (arg);
    }
    return 0;
}

public int copy_file_main (string[] args) {
    if (args.length < 2) {
        error_add (_ ("Source or Target is not defined."));
        error (1);
    }
    string src = srealpath (args[0]);
    string desc = srealpath (args[1]);
    if (isfile (src) || issymlink (src)) {
        if (isdir (desc)) {
            desc += "/" + sbasename (src);
        }
        copy_file (src, desc);
    }else {
        foreach (string file in find (src)) {
            string target=file[src.length:];
            copy_file (file, desc + "/" + target);
        }
    }
    return 0;
}

public int move_file_main (string[] args) {
    if (args.length < 2) {
        error_add (_ ("Source or Target is not defined."));
        error (1);
    }
    string src = srealpath (args[0]);
    string desc = srealpath (args[1]);
    if (isfile (src) || issymlink (src)) {
        if (isdir (desc)) {
            desc += "/" + sbasename (src);
        }
        move_file (src, desc);
    }else {
        foreach (string file in find (src)) {
            string target=file[src.length:];
            move_file (file, desc + "/" + target);
        }
    }
    return 0;
}

void file_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (file_main);
    op.names =  {_ ("file"), "f",  "file"};
    op.help.name = _ ("file");
    op.help.minargs=1;
    op.help.description = _ ("Copy / Move / Remove files or directories.");
    op.help.add_parameter ("--remove", _ ("remove file or directories"));
    op.help.add_parameter ("--copy", _ ("copy file or directories"));
    op.help.add_parameter ("--move", _ ("move file or directories"));
    op.help.add_parameter ("--extract", _ ("extract archive file  (same as extract operation)"));
    add_operation (op);
}
