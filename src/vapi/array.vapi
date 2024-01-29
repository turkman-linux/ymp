[CCode (cheader_filename = "ymp-extra.h")]
public class array2 {
    public array2();
    int size;
    string[] data;
    public void add(string data);
    public void adds(string[] data);
    public string[] get();
    public int length();
    public void reverse();
    public void uniq();
    public void sort();
    public void insert(string value, int index);
    public void remove(string item);
}
