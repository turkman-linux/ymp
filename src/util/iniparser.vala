//DOC: ## ini parser
//DOC: ini parser library for libinary;
//DOC: ini_variable and ini_section classes are struct. inifile class is actual parser.;

//DOC: ### class ini_variable()
//DOC: struct for ini variables;
//DOC: Example usage:;
//DOC: ```vala
//DOC: var inivar = new ini_variable(); 
//DOC: inivar.name = "colorize"; 
//DOC: inivar.value = "false"; 
//DOC: ```;
public class ini_variable {
    //DOC: `string ini_variable.name`;
    //DOC: `string ini_variable.value`;
    public string name;
    public string value;
}


//DOC: ### class ini_section()
//DOC: struct for ini sections
//DOC: Example usage:;
//DOC: ```vala
//DOC: var inisec = new ini_section(); 
//DOC: inisec.add("debug","false"); 
//DOC: ...
//DOC: stdout.printf(inisec.name); 
//DOC: ```;
public class ini_section {
    ini_variable[] variables = {};
    //DOC: `string ini_section.name:`;
    //DOC: ini section name;
    public string name;
    //DOC: `void ini_section.add(string variable, string value):`;
    //DOC: add ini_variable into ini_section;
    public void add(string variable, string value){
        ini_variable v = new ini_variable();
        v.name = variable;
        v.value = value;
        variables += v;
    }
    //DOC: `string ini_section.get(string name):`;
    //DOC: get ini_variable value by variable name
    public string get(string name){
        foreach (ini_variable variable in variables){
            if (variable.name == name){
                return variable.value;
            }
        }
        return "";
    }
    //DOC: `string[] ini_section.get_variables():`
    //DOC: return ini_variable names in ini_section
    public string[] get_variables(){
        string[] keys = {};
        foreach (ini_variable variable in variables){
            keys += variable.name;
        }
        return keys;
    }
}
//DOC: ### class inifile()
//DOC: ini file parser;
//DOC: Example usage:;
//DOC: ``` vala
//DOC: var ini = new inifile(); 
//DOC: ini.load("/etc/inary.conf");
//DOC: var is_debug =  (ini.get("inary", "debug") == "true"); 
//DOC: ```;
public class inifile {

    ini_section[] sections = {};

    //DOC: `void inifile.load(string path):`;
    //DOC: load ini file from **path**;
    public void load(string path){
        if (path == null){
            return;
        }
        ini_section cur_section = new ini_section();
        foreach (string line in split(readfile(path),"\n")){
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
                string variable = split(line,"=")[0];
                string value = split(line,"=")[1];
                if (variable != null && value != null){
                    cur_section.add(variable,value);
                }
            }
        }
        if (cur_section.name != null){
            sections += cur_section;
        }
    }
    //DOC: `string inifile.get(string name, string variable):`;
    //DOC: get value from ini file by section name and variable name.;
    public string get(string name, string variable){
        foreach (ini_section section in sections){
            if (section.name == name){
                return section.get(variable);
            }
        }
        return "";
    }
    //DOC: `string[] inifile.get_variables(string name):`;
    //DOC: get variable names by section name;
    public string[] get_variables(string name){
        foreach (ini_section section in sections){
            if (section.name == name){
                return section.get_variables();
            }
        }
        return {};
    }
    //DOC: `string[] inifile.get_sections():`;
    //DOC: get section names from ini;
    public string[] get_sections(){
        string[] keys = {};
        foreach (ini_section section in sections){
            keys += section.name;
        }
        return keys;
    }
    //DOC: `string inifile.dump():`;
    //DOC: print inifile data;
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
