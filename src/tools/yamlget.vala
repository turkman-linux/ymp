int main(string[] args){
    if (args.length < 3){
        print_stderr("Usage: iniget [file] [path]");
        return 1;
    }
    var file = args[1];
    var path = args[2];
    var yaml = new yamlfile();
    yaml.load(file);
    var data = yaml.get(path);
    if(args.length > 3){
        var fdata = yaml.get_value(data,args[3]);
        if(fdata==""){
            foreach(string item in yaml.get_array(data,args[3])){
                fdata += item +"\n";
            }
            data = yaml.trim(fdata);
        }else{
            data = fdata;
        }
    }
    print(data);
    return 0;
}
