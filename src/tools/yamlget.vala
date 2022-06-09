int main(string[] args){
    inary_init(args);
    string[] new_args = argument_process(args);
    if (new_args.length < 3){
        print_stderr("Usage: iniget [file] [path]");
        return 1;
    }
    var file = new_args[1];
    var path = new_args[2];
    var yaml = new yamlfile();
    yaml.load(file);
    var data = yaml.get(path);
    if(new_args.length > 3){
        var fdata = yaml.get_value(data,new_args[3]);
        if(fdata==""){
            foreach(string item in yaml.get_array(data,new_args[3])){
                fdata += item +"\n";
            }
            data = trim(fdata);
        }else{
            data = fdata;
        }
    }
    print(data);
    return 0;
}
