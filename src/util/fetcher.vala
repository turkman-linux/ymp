public delegate void fetcher_process(double current, double total, string filename);
private fetcher_process fetcher_proc;
public int fetcher_vala(double current, double total, string filename){
    fetcher_proc(current, total, filename);
    return 0;
}

public void set_fetcher_progress(fetcher_process proc){
    fetcher_proc =  (fetcher_process) proc;
}

