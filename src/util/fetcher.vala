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

using Curl;

private string fetcher_data;
private int fetcher_data_size;
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
        for(int i = 0; i < total_size; i++) {
             fetcher_data_output_steam.write (ptr[i].to_string().data);
        }
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


//DOC: `void set_fetcher_progress(fetcher_process proc):`;
//DOC: set fetcher progressbar hanndler.;
//DOC: For example:;
//DOC: ```vala
//DOC: public void progress_bar(int current, int total, string filename){
//DOC:    ...
//DOC: }
//DOC: set_fetcher_progress(progress_bar); 
//DOC: ```;
public void set_fetcher_progress(fetcher_process proc){
    fetcher_proc = proc;
}

//DOC: `bool fetch(string url, string path):`;
//DOC: download file content and write to file;
public bool fetch(string url, string path){
    fetcher_filename = path;
    var file = File.new_for_path (path);
    if (file.query_exists ()) {
        file.delete ();
    }
    fetcher_data_output_steam = new DataOutputStream (file.create (FileCreateFlags.REPLACE_DESTINATION));
    EasyHandle handle = new EasyHandle();
    handle.setopt(Option.URL, url);
    #if debug
        handle.setopt(Option.VERBOSE, 1);
    #else
        handle.setopt(Option.VERBOSE, 0);
    #endif
    handle.setopt(Option.STDERR, 1);
    handle.setopt(Option.USERAGENT, get_value("useragent"));

    handle.setopt(Option.WRITEFUNCTION, WriteFileCallback);
    handle.setopt(Option.NOPROGRESS, 0);
    handle.setopt(Option.PROGRESSFUNCTION, progress_callback);

    handle.perform();
    int i;
    handle.getinfo(Info.RESPONSE_CODE, out i);
    return i == 200;
}

//DOC: `bool fetch_string(string url, string path):`;
//DOC: download file content and return as string;
public string fetch_string(string url){
    fetcher_data = "";
    EasyHandle handle = new EasyHandle();
    handle.setopt(Option.URL, url);
    #if debug
        handle.setopt(Option.VERBOSE, 1);
    #else
        handle.setopt(Option.VERBOSE, 0);
    #endif
    handle.setopt(Option.STDERR, 1);
    handle.setopt(Option.USERAGENT, get_value("useragent"));

    handle.setopt(Option.WRITEFUNCTION, WriteMemoryCallback);
    handle.perform();
    int i;
    handle.getinfo(Info.RESPONSE_CODE, out i);
    if(i==200){
       return fetcher_data;
    }
    return "";
}
#endif
