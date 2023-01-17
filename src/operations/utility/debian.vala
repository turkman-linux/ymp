public int debian_main(string[] args){
    string output = get_value("output");
    if(output == ""){
        output=pwd();
    }
    if(get_bool("extract")){
        foreach(string arg in args){
            deb_extract(arg,output);
        }
    }else if(get_bool("create")){
        foreach(string arg in args){
            deb_create(arg,output);
        }
    }
    
    
    if(get_bool("update-catalog")){
        debian_update_catalog();
    }if(get_bool("get-pkgname")){
        foreach(string arg in args){
            print(find_debian_pkgname_from_catalog(arg));
        }
    }
    
    if(get_bool("install")){
        set_bool("convert",true);
    }if(get_bool("convert")){
        foreach(string arg in args){
            debian_convert(srealpath(arg));
        }
    }
    return 0;
}

void debian_init(){
    var h = new helpmsg();
    h.name = _("debian");
    h.description = _("Debian package operations");
    h.add_parameter(colorize(_("Package options"),magenta),"");
    h.add_parameter("--extract",_("Extract debian package"));
    h.add_parameter("--create",_("Create debian package"));
    h.add_parameter("--convert",_("Convert debian package to ymp package"));
    h.add_parameter(colorize(_("Install options"),magenta),"");
    h.add_parameter("--install",_("Install debian package")+colorize(colorize(colorize(" (%s)",red),5),1).printf(_("Dangerous")));
    h.add_parameter(colorize(_("Catalog options"),magenta),"");
    h.add_parameter("--update-catalog",_("Update debian catalog from debian repository"));
    h.add_parameter("--get-pkgname",_("Get source package name from catalog"));
    h.add_parameter("--mirror",_("Debian mirror url"));
    add_operation(debian_main, {_("debian"),"deb","debian"},h);
}
