public class yamlfile {

    public string data;
    private int offset = 0;


    public void load(string path){
        debug("Loading yaml from: "+path);
        data = readfile(path);
    }

    public string get(string path){
       if(data == null){
            return "";
        }
        return get_area(data,path);
        
    }    
    public bool has_area(string fdata, string path){
        foreach(string line in split(trim(fdata),"\n")){
            if (startswith(line,path+":")){
                return true;
            }
        }
        return false;
    }

    public string[] get_area_list(string fdata, string path){
        string[] ret = {};
        offset = find_first_offset(fdata,path);
        int data_length = split(fdata,"\n").length;
        while(offset < data_length-1){
            string data = get_area_single(fdata,path);
            ret += data;
            offset += split(data,"\n").length + 1;
        }
        return ret;
    }
    
    private int find_first_offset(string fdata, string name){
        int i=0;
        foreach(string line in split(trim(fdata),"\n")){
            i+=1;
            if(startswith(line, name+":")){
                return i-1;
            }
        }
        return i-1;
    }
    public string get_value(string data,string name){
        foreach(string line in split(trim(data),"\n")){
            if(line.length < name.length+1){
                continue;
            }
            int level = count_tab(line);
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
        foreach(string line in split(fdata,"\n")){
            if(line[0:2] == "- "){
                array += line[1:];
            }
        }
        return array;
    }

    public string get_area(string data, string path){
        string tmp = data;
        foreach(string item in split(path,".")){
            tmp = get_area_single(tmp,item);
        }
        return tmp;
    }

    private string get_area_single(string fdata,string path){
        if(fdata == null){
            return "";
        }
        int level = 0;
        bool e = false;
        string area = "";
        int i = 0;
        foreach(string line in split(trim(fdata),"\n")){
            i +=1;
            if(i<offset){
                continue;
            }
            level = count_tab(line);
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
}
