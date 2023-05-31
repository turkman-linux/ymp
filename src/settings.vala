
//DOC: ## Settings functions
//DOC: ymp configuration functions
private string CONFIG;
private string DESTDIR;

private yamlfile config_yaml;
private void settings_init () {
    if (DESTDIR == null) {
        DESTDIR = "/";
    }
    if (CONFIGDIR == null) {
        CONFIGDIR = "/etc/";
    }
    if (CONFIG == null) {
        CONFIG = DESTDIR + "/" + CONFIGDIR + "/ymp.yaml";
    }
    config_yaml = new yamlfile ();
    set_value_readonly ("destdir", DESTDIR);
    set_value_readonly ("config", CONFIG);
    set_value_readonly ("version", VERSION);
    string area = "";
    string value = "";
    if (isfile (CONFIG)) {
        config_yaml.load (CONFIG);
        foreach (string section in config_yaml.get_area_names (config_yaml.data)) {
            area = config_yaml.get_area (config_yaml.data, section);
            foreach (string variable in config_yaml.get_area_names (area)) {
                value = config_yaml.get_value (area, variable);
                if (section == "ymp") {
                    set_value (variable, value);
                }else {
                    set_value (section + ":" + variable, value);
                }
            }
        }
    }else {
        warning (_ ("Config file does not exists: %s").printf (CONFIG));
    }
    if (get_env ("USE") != null) {
        set_value ("USE", get_env ("USE"));
    }else {
        area = config_yaml.get_area (config_yaml.data, "ymp");
        set_value ("USE", config_yaml.get_value (area, "use"));
    }
    #if DEBUG
    if (get_bool ("debug")) {
        set_env ("G_MESSAGES_DEBUG", "all");
        set_env ("G_DEBUG", "fatal_warnings");
    }
    #endif
}

//DOC: `string get_config (string section, string path):`
//DOC: get config variable from ymp config
public string get_config (string section, string path) {
    string fdata = config_yaml.get_area (config_yaml.data, section);
    return config_yaml.get_value (fdata, path);
}


//DOC: `void set_destdir (string rootfs):`
//DOC: change distdir
public void set_destdir (string rootfs) {
    DESTDIR=srealpath (rootfs);
    info (_ ("Destination directory has been changed: %s").printf (DESTDIR));
    settings_init ();
}

//DOC: `string get_storage ():`
//DOC: get ymp storage directory. (default: /var/lib/ymp)
public string get_storage () {
    return DESTDIR + "/" + STORAGEDIR;
}

//DOC: `string get_configdir ():`
//DOC: get ymp storage directory. (default: /etc/)
public string get_configdir () {
    return DESTDIR + "/" + CONFIGDIR;
}

public string get_destdir () {
    if (DESTDIR == null) {
        DESTDIR = "/";
    }
    return DESTDIR;
}

//DOC: `string get_storage ():`
//DOC: get ymp storage directory. (default: /var/lib/ymp)
public string get_build_dir () {
    return DESTDIR + "/tmp/ymp-build/";
}

private string get_metadata_path (string name) {
    return get_storage () + "/metadata/" + name + ".yaml";
}

//DOC: `void set_config (string path):`
//DOC: change ymp config file (default /etc/ymp.yaml)
public void set_config (string path) {
    CONFIG=srealpath (path);
    settings_init ();
}
private void parse_args (string[] args) {
    foreach (string arg in args) {
        if (arg == "--") {
            return;
        }
        if (startswith (arg, "--")) {
            var argname = arg[2:];
            if (argname == "allow-oem") {
                    set_value_readonly ("allow-oem", "true");
            }else if (arg.contains ("=")) {
                var name = ssplit (argname, "=")[0];
                var value = argname[name.length + 1:];
                if (name == "use") {
                    set_value (name, value);
                }else if (name == "destdir") {
                    set_destdir (value);
                }else if (name == "config") {
                    set_config (value);
                }else {
                    set_value (name, value);
                }
            }else {
                set_bool (argname, true);
            }
        }
    }
    if (get_env ("NO_COLOR") != null) {
        set_bool ("no-color", true);
    }
}
