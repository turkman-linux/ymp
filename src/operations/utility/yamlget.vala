public int yamlget_main(string[] args){
    ymp_init(args);
    string[] new_args = argument_process(args);
    var file = new_args[0];
    var path = new_args[1];
    var yaml = new yamlfile();
    yaml.load(file);
    var data = yaml.get(path);
    if(new_args.length > 2){
        var fdata = yaml.get_value(data,new_args[2]);
        if(fdata==""){
            foreach(string item in yaml.get_array(data,new_args[2])){
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

void yamlget_init(){
    var h = new helpmsg();
    h.name = _("yamlget");
    h.minargs = 2;
    h.usage = _("yamlget [file] [path]");
    h.description = _("Parse yaml files");
    add_operation(yamlget_main,{_("yamlget"),"yamlget","yaml"},h);
}
