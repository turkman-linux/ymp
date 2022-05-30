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
public string[] list_values(){
    string[] ret = {};
    foreach(variable var in vars){
        ret += var.name;
    }
    return ret;
}
