
public class array{
    //DOC: ## class array
    //DOC: fast and easy usable array library
    //DOC: Example usage:
    //DOC: ```vala
    //DOC: var a = new array();
    //DOC: a.add("item1");
    //DOC: string[] b = {"item2","item3"};
    //DOC: a.adds(b);
    //DOC: a.remove("item2");
    //DOC: a.insert("item4",2);
    //DOC: string[] aa = a.get();
    //DOC: a.pop(0);
    //DOC: ```

    private string[] a;
    private int rmsize=0;
    //DOC: `void reverse():`
    //DOC: reverse array order
    public void reverse(){
        a = get();
        int i = a.length;
        string[] new_a = {};
        while(i > 0){
            i -=1;
            new_a += a[i];
        }
        a = new_a;
    }
    
    public void sort(){
        a = get();
        csort(a,a.length);
    }

    //DOC: `void add(string item):`
    //DOC: add item into array
    public void add(string item){
        if(item != "" && item != null){
            a += item;
        }
    }
    
    //DOC: `void adds(string[] arr):`
    //DOC: add item list into array
    public void adds(string[] arr){
        if (arr == null || arr.length == 0){
            return;
        }
        foreach(string item in arr){
            add(item);
        }
    }
    
    //DOC: `void remove(string item):`
    //DOC: remove item from array
    public void remove(string item){
        if(item == "" || item == null){
            return;
        }
        int i=0;
        while(i < a.length){
            if(a[i] == item){
                a[i] = null;
                rmsize++;
                break;
            }
            i++;
        }
    }
    
    //DOC: `void pop(int index):`
    //DOC: remove item from array by index number
    public void pop(int index){
        if(index >= a.length){
            return;
        }
        a[index] = null;
        rmsize++;
    }
    
    //DOC: `void insert(string item, int index):`
    //DOC: insert item into array by number
    public void insert(string item, int index){
        string[] new_a = {};
        int i=0;
        while(i < a.length){
            if(i == index && item != null){
                new_a += item;
            }
            new_a += a[i];
            i++;
        }
        a = new_a;
    }
    
    //DOC: `bool has(string item):`
    //DOC: check item exists in array
    public bool has(string item){
        return item in a;
    }
    
    //DOC: `string[] get():`
    //DOC: return as string array
    public string[] get(){
        if(rmsize == 0){
            return a;
        }else{
            string[] new_a = {};
            foreach(string item in a){
                if(item != null){
                    new_a+=item;
                }
            }
            rmsize = 0;
            return new_a;
        }
    }
    
    //DOC: `void set(string[] new_a):`
    //DOC: replace with new array
    public void set(string[] new_a){
        a = new_a;
    }
    
    //DOC: `long size()`;
    //DOC: return array length
    public long length(){
        return a.length-rmsize;
    }
}
