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
    foreach (variable varx in vars) {
        if (varx.name == name.up ()) {
            return;
        }else if (varx.name == name.down ()) {
            varx.value = value;
            return;
        }
    }
    #if DEBUG
//    stderr.printf ("Set value: "+name+"="+value+"\n");
    #endif
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

//DOC: `void clear_env ():`
//DOC: remove all environmental variable except **PATH**
public void clear_env () {
    foreach (string name in GLib.Environment.list_variables ()) {
        GLib.Environment.unset_variable (name);
    }
}

private string DISTRO;
public string get_distro_name (){
    if (DISTRO!=null){
        return DISTRO;
    }
    string os_release = readfile("/etc/os-release");
    foreach(string line in ssplit(os_release,"\n")){
        if (startswith (line, "NAME=")){
            DISTRO=line[5:];
        }
    }
    if(DISTRO==null){
        DISTRO="Unknown";
    }
    return DISTRO;
}
