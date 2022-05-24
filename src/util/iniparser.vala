public class ini_variable {
    public string name;
    public string value;
}

public class ini_section {
    ini_variable[] variables = {};
    public string name;
    public void add(string variable, string value){
        ini_variable v = new ini_variable();
        v.name = variable;
        v.value = value;
        variables += v;
    }
    public string get(string name){
        foreach (ini_variable variable in variables){
            if (variable.name == name){
                return variable.value;
            }
        }
        return "";
    }
    
    public string[] get_variables(){
        string[] keys = {};
        foreach (ini_variable variable in variables){
            keys += variable.name;
        }
        return keys;
    }
}

public class inifile {

    ini_section[] sections = {};

    public void load(string path){
        ini_section cur_section = new ini_section();
        foreach (string line in readfile(path).split("\n")){
            if (line[0] == '[' && line[line.length-1] == ']'){
                var section = new ini_section();
                section.name = line[1:line.length-1];
                if (cur_section.name != section.name){
                    if (cur_section.name != null){
                        sections += cur_section;
                    }
                    cur_section = section;
                }
            }else{
                string variable = line.split("=")[0];
                string value = line.split("=")[1];
                if (variable != null && value != null){
                    cur_section.add(variable,value);
                }
            }
        }
        if (cur_section.name != null){
            sections += cur_section;
        }
    }
    public string get(string name, string variable){
        foreach (ini_section section in sections){
            if (section.name == name){
                return section.get(variable);
            }
        }
        return "";
    }
    public string[] get_variables(string name){
        foreach (ini_section section in sections){
            if (section.name == name){
                return section.get_variables();
            }
        }
        return {};
    }
    public string[] get_sections(){
        string[] keys = {};
        foreach (ini_section section in sections){
            keys += section.name;
        }
        return keys;
    }
    public string dump(){
        string data="";
        foreach (ini_section section in sections){
            data += "["+section.name+"]";
            foreach (string variable in section.get_variables()){
                data += variable+"="+section.get(variable);
            }
        }
        return data;
    }
}
