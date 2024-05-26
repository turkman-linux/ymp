[CCode (cheader_filename = "archive_extract.h")]
public class archive {
    public archive();
    public void load(string path);
    public void set_target(string path);
    public void extract_all();
    public void extract(string path);
    public void create();
    public void add(string path);
    public string readfile(string path);
    public string[] list_files();
    public bool is_archive(string path);
}
