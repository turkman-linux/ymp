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

public string[] split(string data, string f){
    if(data == null || f == null){
        debug("empty data");
        return {};
    }else if(! data.contains(f)){
        return {data};
    }
    return data.split(f);
}

public string trim(string data){
    int min = -1;
    string new_data = "";
    foreach(string line in split(data,"\n")){ 
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
    foreach(string line in split(data,"\n")){
        if(line.length == 0){
            continue;
        }
        new_data += line[min:]+"\n";
    }
    return new_data[:new_data.length-1];
}

private int count_tab(string line){
    for(int i = 0; i<line.length;i++){
        if (line[i] != ' '){
            return i;
        }
    }
    return 0;
}
