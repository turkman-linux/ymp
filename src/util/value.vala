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

class variable_integer {
    public string name;
    public int value;
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
class variable {
    public string name;
    public string value;
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

