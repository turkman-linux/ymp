[CCode (cheader_filename = "array.h")]
public class array {
    public array();
    int size;
    string[] data;
    public void add(string data);
    public void adds(string[] data);
    public string[] get();
    public string get_string();
    public int length();
    public void reverse();
    public void uniq();
    public bool has(string item);
    public void set(string[] new_data);
    public void pop(int index);
    public void sort();
    public void insert(string value, int index);
    public void remove(string item);
}
