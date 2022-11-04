//DOC: ## String functions
//DOC: easy & safe string operation functions.

//DOC: `string join(string f, string[] array):`
//DOC: merge array items. insert **f** in between
//DOC: Example usage:
//DOC: ```vala
//DOC: string[] aa = {"hello","world","!"};
//DOC: string bb = join(aa," ");
//DOC: stdout.printf(bb);
//DOC: ```
public string join(string f,string[] array){
    string tmp="";
    if(array == null){
        return "";
    }
    foreach(string item in array){
        if(item != null){
            tmp += item + f;
        }
    }
    if(f.length >= tmp.length){
        return tmp;
    }
    return tmp[0:tmp.length-f.length];
}
//DOC: `string[] ssplit(string data, string f):`
//DOC: safe split function. If data null or empty return empty array.
//DOC: if **f** not in data, return single item array.
public string[] ssplit(string data, string f){
    if(data == null || f == null){
        debug("empty data");
        return {};
    }else if(! data.contains(f)){
        return {data};
    }
    return data.split(f);
}

//DOC: `string trim(string data):`
//DOC: fixes excess indentation
public string trim(string data){
    if(data==null){
        return "";
    }
    int min = -1;
    string new_data = "";
    foreach(string line in ssplit(data,"\n")){
        int level = count_tab(line);
        if(line.length == 0){
            continue;
        }
        if(min == -1 || count_tab(line) < min){
            min = level;
        }
    }
    if(min == -1){
        min = 0;
    }
    foreach(string line in ssplit(data,"\n")){
        if(line.length == 0){
            continue;
        }
        new_data += line[min:]+"\n";
    }
    return new_data[:new_data.length-1];
}
//DOC: `int count_tab(string line):`
//DOC: count indentation level
public int count_tab(string line){
    for(int i = 0; i<line.length;i++){
        if (line[i] != ' '){
            return i;
        }
    }
    return 0;
}

//DOC: `boot startswith(string data, string f):`
//DOC: return true if data starts with f
public bool startswith(string data,string f){
    if(data.length < f.length){
        return false;
    }
    return data[:f.length] == f;
}
//DOC: `bool endswith(string data, string f):`
//DOC: return true if data ends with f
public bool endswith(string data,string f){
    if(data.length < f.length){
        return false;
    }
    return data[data.length-f.length:] == f;
}

//DOC: `string sbasename(string path):`
//DOC: safe basename. return filename
public string sbasename(string path){
    string[] f = ssplit(path,"/");
    return f[f.length-1];
}

//DOC: `string sdirname(string path):`
//DOC: safe dirname. return path name
public string sdirname(string path){
    string[] f = ssplit(path,"/");
    string ret = "";
    if(f.length == 0){
        return "";
    }
    foreach(string g in f[:f.length-1]){
        ret +=g+"/";
    }
    return ret;
}
