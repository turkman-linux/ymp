//DOC: ## String functions
//DOC: easy & safe string operation functions.

//DOC: `public int[] sindex (string f, string[] array)`:
//DOC: Get item index number array in string array.
public int[] sindex (string f, string[] array) {
    int[] ret = {};
    for (int i=0;i < array.length;i++) {
        if (array[i] == f) {
            ret += i;
        }
    }
    return ret;
}

//DOC: `string[] ssplit (string data, string f):`
//DOC: safe split function. If data null or empty return empty array.
//DOC: if **f** not in data, return single item array.
public string[] ssplit (string data, string f) {
    if (data == null || f == null || data.length == 0) {
        debug (_ ("empty data"));
        return {};
    }else if (!data.contains (f) || f.length == 0) {
        return {data};
    }
    string[] ret = {};
    foreach (string i in data.split (f)) {
        if (i.length > 0 && i != null) {
            ret += i;
        }
    }
    return ret;
}

//DOC: `boot startswith (string data, string f):`
//DOC: return true if data starts with f
public bool startswith (string data, string f) {
    if (data.length < f.length) {
        return false;
    }
    return data[:f.length] == f;
}
//DOC: `bool endswith (string data, string f):`
//DOC: return true if data ends with f
public bool endswith (string data, string f) {
    if (data.length < f.length) {
        return false;
    }
    return data[data.length - f.length:] == f;
}

//DOC: `string sbasename (string path):`
//DOC: safe basename. return filename
public string sbasename (string path) {
    debug (_ ("Basename: %s").printf (path));
    string[] f = ssplit (path, "/");
    return f[f.length - 1];
}

//DOC: `string sdirname (string path):`
//DOC: safe dirname. return path name
public string sdirname (string path) {
    debug (_ ("Dirname: %s").printf (path));
    string[] f = ssplit (path, "/");
    string ret = "";
    if (f.length == 0) {
        return "";
    }
    foreach (string g in f[:f.length - 1]) {
        ret +=g + "/";
    }
    if (path[0] == '/') {
        ret = "/" + ret;
    }
    return ret;
}

public string[] uniq (string[] array) {
    string[] ret = {};
    foreach (string item in array) {
        if (! (item in ret)) {
            ret += item;
        }
    }
    return ret;
}

//public string str_add (string str1, string str2);
