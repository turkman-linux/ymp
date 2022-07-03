
public class array{

    private string[] a;
    public void reverse(){
        int i = a.length;
        string[] new_a = {};
        while(i > 0){
            i -=1;
            new_a += a[i];
        }
        a = new_a;
    }
    public void add(string item){
        if(item != "" && item != null){
            a += item;
        }
    }
    public void adds(string[] arr){
        foreach(string item in arr){
            add(item);
        }
    }
    public void remove(string item){
        string[] new_a = {};
        int i=0;
        while(i < a.length){
            if(a[i] != item){
                new_a += a[i];
            }
            i++;
        }
        a = new_a;
    }
    public void pop(int index){
        string[] new_a = {};
        int i=0;
        while(i < a.length){
            if(i != index){
                new_a += a[i];
            }
            i++;
        }
        a = new_a;
    }
    public void insert(string item, int index){
        string[] new_a = {};
        int i=0;
        while(i < a.length){
            if(i == index){
                new_a += item;
            }
            new_a += a[i];
            i++;
        }
        a = new_a;
    }
    public bool has(string item){
        return item in a;
    }
    public string[] get(){
        return a;
    }
    public void set(string[] new_a){
        a = new_a;
    }
}
