public int yamlget_main(string[] args){
    var file = args[0];
    var path = args[1];
    var yaml = new yamlfile();
    yaml.load(file);
    var data = yaml.get(path);
    if(args.length > 2){
        var fdata = yaml.get_value(data,args[2]);
        if(fdata==""){
            foreach(string item in yaml.get_array(data,args[2])){
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
