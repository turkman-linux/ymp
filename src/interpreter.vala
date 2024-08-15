public void add_script(string data) {
    if (data == null || data == "") {
        return;
    }
    foreach(string line in ssplit(data, "\n")) {
        string[] args = split_args(line);
        add_process(args[0], args[1: ]);
    }
}

private extern void no_stdin();
private extern void reset_std();


private class variable_integer {
    public string name;
    public int value;
}

public int ymp_run() {
    variable_integer[] labels = {};
    bool label_found = false;
    int iflevel = 0;
    int last_i = -1;
    for (int i = 0; i < proc.length; i++) {
        debug("Current:%d Last:%d Type:%s".printf(i, last_i, proc[i].type));
        long start_time = get_epoch();
        if (proc[i].type == "label") {
            variable_integer l = new variable_integer();
            l.name = proc[i].args[0];
            l.value = i;
            if (!(l in labels)) {
                labels += l;
            }
            continue;
        }

        if (proc[i].type == "if") {
            process op = new process();
            op.type = proc[i].args[0].strip();
            op.args = proc[i].args[1: ];
            if (iflevel == 0) {
                lock_operation();
                int status = operation_main(op.type, op.args);
                unlock_operation();
                if (status != 0) {
                    iflevel += 1;
                }
            } else {
                iflevel += 1;
            }
            continue;
        } else if (proc[i].type == "endif") {
            iflevel -= 1;
            continue;
        }
        if (iflevel < 0) {
            error_add(_("Line %d:").printf(i)+" "+_("Syntax error: Unexceped endif detected."));
            error(2);
        } else if (iflevel != 0) {
            continue;
        }
        if (proc[i].type == "goto") {
            string name = proc[i].args[0];
            last_i = i;
            label_found = false;
            foreach(variable_integer l in labels) {
                if (l.name == name) {
                    i = l.value;
                    iflevel = 0;
                    label_found = true;
                    break;
                }
            }
            if(!label_found){
                error_add(_("Line %d:").printf(i)+" "+_("label is not defined: %s").printf(name));
                error(2);
            }
            continue;
        }
        if (proc[i].type == "ret") {
            if (last_i >= 0) {
                i = last_i;
                last_i = -1;
            }
            continue;
        }
        lock_operation();
        if (get_bool("disable-stdin")) {
            no_stdin();
        }
        int status = operation_main(proc[i].type, proc[i].args);
        reset_std();
        unlock_operation();
        if (status != 0) {
            string type = proc[i].type;
            error_add(_("Line %d:").printf(i)+" "+_("Process: %s failed. Exited with %d.").printf(type, status));
            error(status);
        }
        float diff = ((float)(get_epoch() - start_time)) / 1000000;
        info(_("Process done in : %f sec").printf(diff));
    }
    return 0;
}

// preprocessor
private static string[] split_args(string line) {
    array ret = new array();
    string cur = "";
    char c = '\0';
    char cc = '\0';
    char qc = '\0';
    int type = 0; // 0 = normal 1 = exec 2 = quota
    for (int i = 0; i < line.length; i++) {
        c = line[i];
        if (c >= 1) {
            cc = line[i - 1];
        }
        if (c == '\\') {
            i += 1;
            if (i >= line.length) {
                error_add("Unexceped line ending!");
                error(31);
            }
            cur += line[i].to_string();
            continue;
        }
        if (c == '`' && cc != '\\') {
            if (type != 0) {
                type = 1;
                ret.add(cur);
                cur = "";
            } else {
                ret.add(getoutput(cur).strip());
                cur = "";
                type = 0;
            }
            continue;
        }
        if ((c == '"' || c == '\'') && cc != '\\') {
            if (type == 2 && qc == c) {
                type = 0;
                qc = '\0';
            } else if (type == 0) {
                type = 2;
                qc = c;
            }
            continue;
        }
        if (c == ' ' && cc != '\\') {
            if (type == 0) {
                ret.add(cur);
                cur = "";
                continue;
            }
        }
        cur += c.to_string();
    }
    if (cur != null && cur != "") {
        ret.add(cur);
    }
    return ret.get();
}
