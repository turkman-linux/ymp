public class yamlfile {

    public string data;
    private int offset = 0;


    public void load(string path){
        data = readfile(path);
    }

    public string get(string path){
       if(data == null){
            return "";
        }
        return get_from_data(data,path);
        
    }    
    public string get_from_data(string data, string path){
        string tmp = data;
        foreach(string item in path.split(".")){
            tmp = get_area(tmp,item);
        }
        return tmp;
    }
    
    public string[] get_area_list(string fdata, string path){
        string[] ret = {};
        int data_length = fdata.split("\n").length;
        while(offset < data_length){
            string data = get_area(fdata,path);
            ret += data;
            offset += data.split("\n").length + 1;
        }
        return ret;
    }
    
    public string get_area(string fdata,string path){
        if(fdata == null){
            return "";
        }
        int level = 0;
        bool e = false;
        string area = "";
        int i = 0;
        foreach(string line in trim(fdata).split("\n")){
            i +=1;
            if(i<offset){
                continue;
            }
            level = c(line);
            if(level == 0){
               if(e){
                   return trim(area);
               }
               if(line == path+":"){
                    e=true;
                    continue;
                }
            }
            if(e){
                area += line + "\n";
            }
        }
        return trim(area);
    }
    private int c(string line){
        for(int i = 0; i<line.length;i++){
            if (line[i] != ' '){
                return i;
            }
        }
        return 0;
    }
    public string trim(string data){
        int min = -1;
        string new_data = "";
        foreach(string line in data.split("\n")){ 
            int level = c(line);
            if(line.length == 0){
                continue;
            }
            if(min == -1 || c(line) < min){
                min = level;
            }
        }
        if(min == -1){
            min = 0;
        }
        foreach(string line in data.split("\n")){
            if(line.length == 0){
                continue;
            }
            new_data += line[min:]+"\n";
        }
        return new_data;
    }
}
