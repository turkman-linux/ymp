public delegate void fetcher_process (double current, double total, string filename);
#if no_libcurl
public bool fetch (string url, string path){
    return 0 == run ("wget -U '"+get_value ("useragent")+"' -c '"+url+"' -O '"+path+"'");
}

public string fetch_string (string url){
    return getoutput ("wget -U '"+get_value ("useragent")+"' -c '"+url+"' -O -");
}

#else

private string old_line;
public void fetcher_vala (double cur, double total, string filename){
    int percent =  (int) (cur*100/total);
    if (percent < 0 || percent > 100){
        return;
    }
    string del="";
    if (!get_bool ("no-color")){
        del = "\b\x1b[A\b\x1b[2K\r";
    }
    string line = del+"%s%d  %s  %s  %s".printf (
        "%",
        percent,
        sbasename (filename),
        GLib.format_size ( (uint64)cur),
        GLib.format_size ( (uint64)total));
    if (line != old_line){
        print_stderr (line);
        old_line = line;
    }
}
#endif
