//DOC: ## Variable functions
//DOC: set or get ymp global variable
//DOC: Example usage:
//DOC: ```vala
//DOC: set_value ("CFLAGS", "-O3");
//DOC: var jobs = get_value ("jobs");
//DOC: if (get_bool ("debug")) {
//DOC:     stderr.printf ("Debug mode enabled");
//DOC: }
//DOC: ```
class variable {
    public string name;
    public string value;
}

class variable_integer {
    public string name;
    public int value;
}

private variable[] vars;

//DOC: `void set_value (string name, string value):`
//DOC: add a global ymp variable as string
public void set_value (string name, string value) {
    if (vars == null) {
        vars = {};
    }
    if (name == null || value == null) {
        return;
    }
    debug("Set value: "+name+"="+value);
    foreach (variable varx in vars) {
        if (varx.name == name.up ()) {
            return;
        }else if (varx.name == name.down ()) {
            return;
        }
    }
    variable varx = new variable ();
    varx.name = name.down ();
    varx.value = value;
    vars += varx;
}

public string[] get_variable_names(){
    string[] ret = {};
    foreach (variable varx in vars) {
        ret += varx.name;
    }
    return ret;
}

private void set_value_readonly (string name, string value) {
    if (vars == null) {
        vars = {};
    }
    if (name == null || value == null) {
        return;
    }
    #if DEBUG
//    stderr.printf ("Set read_only value: "+name+"="+value+"\n");
    #endif
    foreach (variable varx in vars) {
        if (varx.name == name.up ()) {
            varx.value = value;
            return;
        }
    }
    set_value (name, "");
    variable varx = new variable ();
    varx.name = name.up ();
    varx.value = value;
    vars += varx;
}

//DOC: `string get_value (string name):`
//DOC: get a ymp global variable as string
//DOC: big names are read only and only defined by ymp
public string get_value (string name) {
    if (vars == null) {
        vars = {};
    }
    if (name == null) {
        return "";
    }
    #if DEBUG
    //stderr.printf ("Get value: "+name+"\n");
    #endif
    foreach (variable var in vars) {
        if (var.name == name.up ()) {
            return var.value;
        }else if (var.name == name) {
            return var.value;
        }
    }
    return "";
}

//DOC: `bool get_bool (string name):`
//DOC: get a ymp global variable as bool
public bool get_bool (string name) {
    return get_value (name).down () == "true";
}

//DOC: `void set_bool (string name, bool value):`
//DOC: add a global ymp variable as bool
public void set_bool (string name, bool value) {
    debug("Set bool: "+name+"="+value.to_string());
    if (value) {
        set_value (name, "true");
    }else {
        set_value (name, "false");
    }
}

//DOC: `string[] list_values ():`
//DOC: return array of all ymp global value names
public string[] list_values () {
    string[] ret = {};
    foreach (variable var in vars) {
        if (var.value != "") {
            ret += var.name;
        }
    }
    return ret;
}

//DOC: `void set_env (string variable, string value):`
//DOC: add environmental variable
public void set_env (string variable, string value) {
    if (value != null) {
        GLib.Environment.set_variable (variable, value, true);
    }
}

//DOC: `string get_env (string variable):`
//DOC: get a enviranmental variable
public string get_env (string variable) {
    return GLib.Environment.get_variable (variable);
}

//DOC: `string get_home ():`
//DOC: get home directory location
public string get_home () {
    return GLib.Environment.get_home_dir ();
}


private variable[] envs;

//DOC: `void backup_env():`
//DOC: backup environmental variables
public void backup_env(){
    envs = {};
    foreach (string name in GLib.Environment.list_variables ()) {
        variable e = new variable();
        e.name = name;
        e.value = get_env(name);
        envs += e;
    }
}

public string[] get_envs(){
    string[] ret = {};
    foreach (string name in GLib.Environment.list_variables ()) {
        ret += name+"="+get_env(name);
    }
    return ret;
}

//DOC: `void restore_env():`
//DOC: restore environmetal variables
public void restore_env(){
    clear_env();
    foreach(variable e in envs){
        set_env(e.name, e.value);
    }
}


//DOC: `void clear_env ():`
//DOC: remove all environmental variable except **PATH**
public void clear_env () {
    foreach (string name in GLib.Environment.list_variables ()) {
        GLib.Environment.unset_variable (name);
    }
}

