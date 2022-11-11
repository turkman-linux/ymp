public delegate void fetcher_process(double current, double total, string filename);
#if no_libcurl
public bool fetch(string url, string path){
    return 0 == run("wget -U '"+get_value("useragent")+"' -c '"+url+"' -O '"+path+"'");
}

public string fetch_string(string url){
    return getoutput("wget -U '"+get_value("useragent")+"' -c '"+url+"' -O -");
}

public void set_fetcher_progress(fetcher_process proc){
    // dummy function for compability
}

#else
private fetcher_process fetcher_proc;
public int fetcher_vala(double current, double total, string filename){
    if(fetcher_proc!=null){
        fetcher_proc(current, total, filename);
    }
    return 0;
}

public void set_fetcher_progress(fetcher_process proc){
    fetcher_proc =  (fetcher_process) proc;
}
#endif
