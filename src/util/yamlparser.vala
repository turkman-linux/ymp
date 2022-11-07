//DOC: ## Yaml parser
//DOC: yaml file parser library for ymp
//DOC: Example usage:
//DOC: ```vala
//DOC: var yaml = new yamlfile();
//DOC: yaml.load("/var/lib/ymp/metadata/bash.yaml");
//DOC: var pkgarea = yaml.get("ymp.package");
//DOC: var name = yaml.get_value(pkgarea,"name");
//DOC: if(yaml.has_area(pkgarea,"dependencies")){
//DOC:     dependencies = yaml.get_array(pkgarea,"dependencies");
//DOC: }
//DOC: ```
public class yamlfile {

    //DOC: `string yamlfile.data:`
    //DOC: Yaml file content
    public string data;
    private int offset = 0;


    //DOC: `void yamlfile.load(string path):`
    //DOC: load yaml from file
    public void load(string path){
        debug("Loading yaml from: "+path);
        data = readfile(path);
    }

    //DOC: `string yamlfile.get(string path):`
    //DOC: get area from yaml content
    public string get(string path){
       if(data == null){
            return "";
        }
        return get_area(data,path);

    }

    //DOC: `bool yamlfile.has_area(string fdata, string path):`
    //DOC: return true if **fdata** has **path** area
    public bool has_area(string fdata, string path){
        foreach(string line in ssplit(trim(fdata),"\n")){
            if (startswith(line,path+":")){
                return true;
            }
        }
        return false;
    }

    //DOC: `string[] yamlfile.get_area_list(string fdata, string path):`
    //DOC: list all areas the name is **path**
    public string[] get_area_list(string fdata, string path){
        string[] ret = {};
        if(fdata==null){
            return ret;
        }
        offset = find_first_offset(fdata,path);
        debug("Get area list: offset:"+offset.to_string()+" path: "+path);
        int data_length = ssplit(fdata,"\n").length;
        while(offset+1 < data_length-1){
            string data = get_area_single(fdata,path);
            if(data != "" && data != null){
                if(!(data in ret)){
                    ret += data;
                }
                offset += ssplit(data,"\n").length + 1;
            }else{
                offset += 1;
            }
        }
        return ret;
    }

    private int find_first_offset(string fdata, string name){
        int i=0;
        foreach(string line in ssplit(trim(fdata),"\n")){
            i+=1;
            if(startswith(line, name+":")){
                return i-1;
            }
        }
        return i-1;
    }

    //DOC: `string yamlfile.get_value(string data, string name):`
    //DOC: get value from area data
    public string get_value(string data,string name){
        if(data==null){
            return "";
        }
        foreach(string line in ssplit(trim(data),"\n")){
            if(line.length < name.length+1){
                continue;
            }
            int level = count_tab(line);
            if(level == 0 && line[0:name.length+1] == name+":"){
                if(line.length == name.length+1){
                    return "";
                }
                return line[name.length+1:].strip();
            }
        }
        return "";
    }

    //DOC: `string[] yamlfile.get_array(string data, string name):`
    //DOC: get array from area data
    public string[] get_array(string data,string name){
        string[] array = {};
        if(data==null){
            return array;
        }
        string fdata = get_area(data,name);
        foreach(string line in ssplit(fdata,"\n")){
            if(line[0:2] == "- "){
                array += line[1:].strip();
            }
        }
        return array;
    }

    //DOC: `string yamlfile.get_area(string data, string path):`
    //DOC: get area from data
    public string get_area(string data, string path){
        string tmp = data;
        if(data==null){
            return "";
        }
        foreach(string item in ssplit(path,".")){
            tmp = get_area_single(tmp,item);
        }
        return tmp;
    }

    private string get_area_single(string fdata,string path){
        if(fdata == null || fdata == ""){
            return "";
        }
        int level = 0;
        bool e = false;
        string area = "";
        int i = 0;
        if(!has_area(fdata,path)){
            return "";
        }
        foreach(string line in ssplit(trim(fdata),"\n")){
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
