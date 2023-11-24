private class process {
    public string type = "";
    public string[] args = {};
}
private process[] proc;
private process[] proc_backup;

public void add_process(string type, string[] args){
    if(proc == null){
        proc = {};
    }
    process op = new process ();
    op.type = type;
    op.args = args;
    proc += op;
}

public void backup_process(){
    proc_backup = proc;
}

public void restore_process(){
     proc = proc_backup;
}


public void clear_process(){
    proc = {};
}
