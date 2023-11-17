//DOC: ## Yaml parser
//DOC: yaml file parser library for ymp
//DOC: Example usage:
//DOC: ```vala
//DOC: var yaml = new yamlfile ();
//DOC: yaml.load ("/var/lib/ymp/metadata/bash.yaml");
//DOC: var pkgarea = yaml.get ("ymp.package");
//DOC: var name = yaml.get_value (pkgarea,"name");
//DOC: if (yaml.has_area (pkgarea,"dependencies")) {
//DOC:     dependencies = yaml.get_array (pkgarea,"dependencies");
//DOC: }
//DOC: ```
public class yamlfile {

    //DOC: `string yamlfile.data:`
    //DOC: Yaml file content
    public string data;
    private int offset = 0;


    //DOC: `void yamlfile.load (string path):`
    //DOC: load yaml from file
    public void load (string path) {
        debug (_ ("Loading yaml from: %s").printf (path));
        data = readfile_raw (path);
    }

    //DOC: `string yamlfile.get (string path):`
    //DOC: get area from yaml content
    public string get (string path) {
       if (data == null) {
            return "";
        }
        return get_area (data, path);

    }

    //DOC: `bool yamlfile.has_area (string fdata, string path):`
    //DOC: return true if **fdata** has **path** area
    public bool has_area (string fdata, string path) {
        debug (_ ("Has area : %s").printf (path));
        foreach (string line in ssplit (fdata, "\n")) {
            if (startswith (line, path + ":")) {
                return true;
            }
        }
        return false;
    }

    //DOC: `string[] yamlfile.get_area_list (string fdata, string path):`
    //DOC: list all areas the name is **path**
    public string[] get_area_list (string fdata, string path) {
        debug (_ ("Get area list: %s").printf (path));
        string[] ret = {};
        string data="";
        bool e=false;
        foreach (string line in ssplit (fdata, "\n")) {
            if (!startswith (line, " ") && ":" in line) {
                string name = ssplit (line, ":")[0];
                //flush memory to array
                if (data != "") {
                    ret+=trim (data);
                }
                //reset memory
                data="";
                e = (name == path);
            }else if (e && line.strip () != "") {
                data += line + "\n";
            }
        }
        // flush memory for last item
        if (e && data != "") {
            ret += trim (data);
        }
        return ret;
    }

    public string[] get_area_names (string fdata) {
        string[] ret = {};
        debug (_ ("Get area names"));
        foreach (string line in ssplit (fdata, "\n")) {
            if (!startswith (line, " ") && ":" in line) {
                string name = ssplit (line, ":")[0];
                if (! (name in ret)) {
                    ret += name;
                }
            }
        }
        return ret;
    }

    //DOC: `string yamlfile.get_value (string data, string name):`
    //DOC: get value from area data
    public string get_value (string data, string name) {
        debug (_ ("Yaml get value: %s").printf (name));
        if (data == null || data == "") {
            return "";
        }
        bool e = false;
        string ret = "";
        foreach (string line in ssplit (data, "\n")) {
            if (line.length < name.length + 1) {
                continue;
            }
            if (e) {
                if (startswith (line, " ")) {
                    ret += line + "\n";
                } else {
                    return trim(ret);
                }
                continue;
            }
            if (startswith (line, name + ":")) {
                if (endswith(line, "|")) {
                    e = true;
                    continue;
                }
                ret = line[name.length + 1:].strip ();
                debug(" --> %s".printf(ret));
                return ret;
            }
        }
        return trim(ret);
    }

    //DOC: `string[] yamlfile.get_array (string data, string name):`
    //DOC: get array from area data
    public string[] get_array (string data, string name) {
        debug (_ ("Yaml get array: %s").printf (name));
        string[] array = {};
        if (data == null || data == "") {
            return array;
        }
        string fdata = get_area (data, name);
        foreach (string line in ssplit (fdata, "\n")) {
            if (startswith (line, "- ")) {
                array += line[1:].strip ();
            }
        }
        debug(" --> %d item".printf(array.length));
        return array;
    }

    //DOC: `string yamlfile.get_area (string data, string path):`
    //DOC: get area from data
    public string get_area (string data, string path) {
        debug (_ ("Get area : %s").printf (path));
        string tmp = data;
        if (data == null || data == "") {
            return "";
        }
        foreach (string item in ssplit (path, ".")) {
            tmp = get_area_single (tmp, item);
        }
        return tmp;
    }

private string get_area_single(string fdata, string path) {
    debug(_ ("Get area single: %s").printf(path));

    if (fdata == null || fdata == "") {
        return "";
    }

    bool e = false;
    StringBuilder area_builder = new StringBuilder();
    int i = 0;

    string[] lines = ssplit(fdata, "\n");
    foreach (string line in lines) {
        i += 1;
        if (i < offset) {
            continue;
        }

        if (line[0] != ' ') {
            if (e) {
                return trim(area_builder.str);
            }

            if (line == path + ":") {
                e = true;
                continue;
            }
        }

        if (e) {
            area_builder.append(line + "\n");
        }
    }

    return trim(area_builder.str);
}


}
