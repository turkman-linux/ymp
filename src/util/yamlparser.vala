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
        return get_area(data,path);
        
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
    
    public string get_value(string data,string name){
        foreach(string line in trim(data).split("\n")){
            if(line.length < name.length+1){
                continue;
            }
            int level = c(line);
            if(level == 0 && line[0:name.length+1] == name+":"){
                if(line.length == name.length+1){
                    return "";
                }
                return trim(line[name.length+1:]);
            }
        }
        return "";
    }

    public string[] get_array(string data,string name){
        string[] array = {};
        string fdata = get_area(data,name);
        foreach(string line in fdata.split("\n")){
            if(line[0:2] == "- "){
                array += line[1:];
            }
        }
        return array;
    }
    
    public string get_area(string fdata,string path){
        string area = fdata;
        foreach(string item in path.split(".")){
            if(area == null){
                return "";
            }
            int level = 0;
            bool e = false;
            int i = 0;
            string tmp = "";
            foreach(string line in trim(area).split("\n")){
                i +=1;
                if(i<offset){
                    continue;
                }
                level = c(line);
                if(level == 0){
                   if(e){
                       return trim(tmp);
                   }
                   if(line == item+":"){
                        e=true;
                        continue;
                    }
                }
                if(e){
                    tmp += line + "\n";
                }
            }
            area = trim(tmp);
        }
        return area;
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
        return new_data[:new_data.length-1];
    }
}
