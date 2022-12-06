public int template_main(string[] args){
    string data="#!/usr/bin/env bash\n";
    data += "name='"       +str_or_def("name","")+"'\n";
    data += "release="     +"'1'\n";
    data += "version='"    +str_or_def("version","1.0")+"'\n";
    data += "url='"        +str_or_def("homepage","https://example.org")+"'\n";
    data += "description='"+str_or_def("description","Package description missing")+"'\n";
    data += "email='"      +str_or_def("email",get_gitconfig_variable("email"))+"'\n";
    data += "maintainer='" +str_or_def("maintainer",get_gitconfig_variable("name"))+"'\n";
    data += "license=('"   +str_or_def("license","GPLv3")+"')\n";
    data += "source=('"    +str_or_def("source","")+"')\n";
    data += "depends=("    +str_or_def("depends"," ")+")\n";
    data += "makedepends=("    +str_or_def("makedepends"," ")+")\n";
    data += "md5sums=('FIXME')\n";
    data += "uses=()\n";
    data += "arch=('"    +getArch()+"')\n\n";

    data += "cd $name-$version\n\n";
    string buildtype = get_value("build-type");
    if(buildtype == "autotool" || buildtype == ""){
        data += "setup(){\n";
        data += "    [[ -f ./autogen.sh ]] && ./autogen.sh\n";
        data += "    ./configure --prefix=/usr \\\n";
        data += "        --libdir=/usr/lib64/"+str_or_def("name","")+"\n";
        data += "}\n\n";
        data += "build(){\n";
        data += "    make -j`nproc`\n";
        data += "}\n\n";
        data += "package(){\n";
        data += "    make install -j`nproc`\n";

    }else if(buildtype == "cmake" || buildtype == ""){
        data += "setup(){\n";
        data += "    mkdir build\n";
        data += "    cd build\n";
        data += "    cmake -DCMAKE_INSTALL_PREFIX=/usr \\\n";
        data += "        -DCMAKE_INSTALL_LIBDIR=lib64/"+str_or_def("name","")+" ..\n";
        data += "}\n\n";
        data += "build(){\n";
        data += "    cd build\n";
        data += "    make -j`nproc`\n";
        data += "}\n\n";
        data += "package(){\n";
        data += "    cd build\n";
        data += "    make install -j`nproc`\n";

    }else if(buildtype == "meson" || buildtype == ""){
        data += "setup(){\n";
        data += "    meson setup build --prefix=/usr \\\n";
        data += "        --libdir=/usr/lib64/"+str_or_def("name","")+"\n";
        data += "}\n\n";
        data += "build(){\n";
        data += "    ninja -C build\n";
        data += "}\n\n";
        data += "package(){\n";
        data += "    ninja install -C build\n";

    }else{
        data += "setup(){\n";
        data += "    :\n";
        data += "}\n\n";
        data += "build(){\n";
        data += "    :\n";
        data += "}\n\n";
        data += "package(){\n";
        data += "    :\n";
    }
    data += "    mkdir -p ${DESTDIR}/etc/ld.so.conf.d/\n";
    data += "    echo \"/usr/lib64/"+str_or_def("name","")+"\" > ${DESTDIR}/etc/ld.so.conf.d/"+str_or_def("name","")+".conf\n";
    data += "}\n\n";

    if(get_bool("ask")){
        print(colorize("Please check ympbuild:",blue));
        print(data);
        if(!yesno(colorize("Is it OK ?",red))){
            return 1;
        };
    }
    string target=srealpath(str_or_def("output",""));
    error(1);
    print(colorize("Creating template: ",yellow)+target);
    create_dir(target);
    writefile(target+"/ympbuild",data);
    return 0;
}

private string get_gitconfig_variable(string variable){
    string gitconfig = srealpath(get_home()+"/.gitconfig");
    if(isfile(gitconfig)){
        info("Reading gitconfig:"+gitconfig);
        foreach(string line in readfile(gitconfig).split("\n")){
            if(variable+" =" in line){
                return ssplit(line,"=")[1].strip();
            }
        }
    }
    return "";
}

private string str_or_def(string val,string def){
    string f = get_value(val);
    if(f!=""){
        return f;
    }
    if(def==""){
        error_add("Variable '"+val+"' is not defined. please use --"+val);
    }
    return def;
}

void template_init(){
    var h = new helpmsg();
    h.name = "template";
    h.description = "Create ympbuild from template";
    h.add_parameter("--name", "package name");
    h.add_parameter("--version", "package version");
    h.add_parameter("--homepage", "package homepage");
    h.add_parameter("--description", "package description");
    h.add_parameter("--depends", "package dependencies");
    h.add_parameter("--makedepends", "package build dependencies");
    h.add_parameter("--email", "package creator email");
    h.add_parameter("--maintainer", "package maintainer");
    h.add_parameter("--license", "package license");
    h.add_parameter("--source", "package source");
    h.add_parameter("--build-type", "package build-type (autotool cmake meson)");
    h.add_parameter("--output", "ympbuild output directory");
    add_operation(template_main,{"template","t"},h);
}
