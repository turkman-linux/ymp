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

private string fetcher_data;
private DataOutputStream fetcher_data_output_steam;
private string fetcher_filename;

private size_t WriteMemoryCallback(char* ptr, size_t size, size_t nmemb, void* data) {

    size_t total_size = size*nmemb;
    for(int i = 0; i < total_size; i++) {
        fetcher_data += ptr[i].to_string();
    }
    return total_size;
}

private size_t WriteFileCallback(char* ptr, size_t size, size_t nmemb, void* data) {
    size_t total_size = size*nmemb;
    try {
        #if debug
            // slow and write byte by byte
            for(int i = 0; i < total_size; i++) {
                 fetcher_data_output_steam.put_byte(ptr[i]);
            }
        #else
            // fast and default way
            uint8[] text = {};
            for(int i = 0; i < total_size; i++) {
                text += ptr[i];
            }
            long written = 0;
            while (written < text.length) {
                written += fetcher_data_output_steam.write (text[written:text.length]);
            }
        #endif
    } catch (Error e) {
        error_add(e.message);
    }
    return total_size;
}

private int progress_callback(void *clientp,  double dltotal, double dlnow, double ultotal, double ulnow){
    if(fetcher_proc != null){
        fetcher_proc(dlnow, dltotal,fetcher_filename);
    }
    return 0;
}

private fetcher_process fetcher_proc;


//DOC: `void set_fetcher_progress(fetcher_process proc):`
//DOC: set fetcher progressbar hanndler.
//DOC: For example:
//DOC: ```vala
//DOC: public void progress_bar(int current, int total, string filename){
//DOC:    ...
//DOC: }
//DOC: set_fetcher_progress(progress_bar);
//DOC: ```
public void set_fetcher_progress(fetcher_process proc){
    fetcher_proc = proc;
}

//DOC: `bool fetch(string url, string path):`
//DOC: download file content and write to file
public bool fetch(string url, string path){
    info(colorize("Download: ",yellow)+url);
    fetcher_filename = path+".part";
    if(isfile(path)){
        return true;
    }
    if(isfile(fetcher_filename)){
        remove_file(fetcher_filename);
    }
    try{
        var file = File.new_for_path (fetcher_filename);
        fetcher_data_output_steam = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
    }catch(Error e){
        error_add(e.message);
        return false;
    }
    Curl.EasyHandle handle = new Curl.EasyHandle();
    handle.setopt(Curl.Option.URL, url);
    #if debug
        handle.setopt(Curl.Option.VERBOSE, 1);
    #else
        handle.setopt(Curl.Option.VERBOSE, 0);
    #endif
    handle.setopt(Curl.Option.STDERR, 1);
    handle.setopt(Curl.Option.FOLLOWLOCATION, 1);
    handle.setopt(Curl.Option.USERAGENT, get_value("useragent"));

    handle.setopt(Curl.Option.WRITEFUNCTION, WriteFileCallback);
    handle.setopt(Curl.Option.NOPROGRESS, 0);
    handle.setopt(Curl.Option.PROGRESSFUNCTION, progress_callback);

    handle.perform();
    int i;
    handle.getinfo(Curl.Info.RESPONSE_CODE, out i);
    if(i == 200){
        if(isfile(fetcher_filename)){
            move_file(fetcher_filename,path);
            return true;
        }
    }
    return false;
}

//DOC: `bool fetch_string(string url, string path):`
//DOC: download file content and return as string
public string fetch_string(string url){
    fetcher_data = "";
    Curl.EasyHandle handle = new Curl.EasyHandle();
    handle.setopt(Curl.Option.URL, url);
    #if debug
        handle.setopt(Curl.Option.VERBOSE, 1);
    #else
        handle.setopt(Curl.Option.VERBOSE, 0);
    #endif
    handle.setopt(Curl.Option.STDERR, 1);
    handle.setopt(Curl.Option.USERAGENT, get_value("useragent"));

    handle.setopt(Curl.Option.WRITEFUNCTION, WriteMemoryCallback);
    handle.perform();
    int i;
    handle.getinfo(Curl.Info.RESPONSE_CODE, out i);
    if(i==200){
       return fetcher_data;
    }
    return "";
}
#endif
