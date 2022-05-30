class variable {
    public string name;
    public string value;
}

variable[] vars;

public void set_value(string name, string value){
    if(vars == null){
        vars = {};
    }
    foreach(variable varx in vars){
        if(varx.name == name){
            varx.value = value;
            return;
        }
    }
    variable varx = new variable();
    varx.name = name;
    varx.value = value;
    vars += varx;
}

public string get_value(string name){
    if(vars == null){
        vars = {};
    }
    foreach(variable var in vars){
        if(var.name == name){
            return var.value;
        }
    }
    return "";
}

public bool get_bool(string name){
    return get_value(name) == "true";
}

public void set_bool(string name,bool value){
    if(value){
        set_value(name,"true");
    }else{
        set_value(name,"false");
    }
}

public string[] list_values(){
    string[] ret = {};
    foreach(variable var in vars){
        ret += var.name;
    }
    return ret;
}

public void set_env(string variable,string value){
    GLib.Environment.set_variable(variable,value,true);
}

public string get_env(string variable){
    return GLib.Environment.get_variable(variable);
}

public void clear_env(){
    string path = get_env("PATH");
    foreach(string name in GLib.Environment.list_variables()){
        GLib.Environment.unset_variable(name);
    }
    set_env("PATH",path);
}
