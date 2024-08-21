private static int template_main (string[] args) {
    string data="#!/usr/bin/env bash\n";
    data += "name='" + str_or_def ("name", "") + "'\n";
    data += "release=" + "'1'\n";
    data += "version='" + str_or_def ("version", "1.0") + "'\n";
    data += "url='" + str_or_def ("homepage", "https://example.org") + "'\n";
    data += "description='" + str_or_def ("description", "Package description missing") + "'\n";
    data += "email='" + str_or_def ("email", get_gitconfig_variable ("email")) + "'\n";
    data += "maintainer='" + str_or_def ("maintainer", get_gitconfig_variable ("name")) + "'\n";
    data += "license=('" + str_or_def ("license", "GPLv3") + "')\n";
    data += "source=('" + str_or_def ("source", " ") + "')\n";
    data += "depends=(" + str_or_def ("depends", " ") + ")\n";
    data += "makedepends=(" + str_or_def ("makedepends", " ") + ")\n";
    data += "sha256sums=('FIXME')\n";
    data += "group=()\n";
    data += "uses=()\n";
    data += "arch=('" + getArch () + "')\n\n";

    data += "cd $name-$version\n\n";
    string buildtype = get_value ("build-type");
    if (buildtype == "autotool" || buildtype == "") {
        data += "setup () {\n";
        data += "    ./configure --prefix=/usr \\\n";
        data += " --libdir=/usr/lib64/\n";
        data += "}\n\n";
        data += "build () {\n";
        data += "    make $jobs\n";
        data += "}\n\n";
        data += "package () {\n";
        data += "    make install $jobs\n";

    }else if (buildtype == "cmake") {
        data += "setup () {\n";
        data += "    mkdir build\n";
        data += "    cd build\n";
        data += "    cmake -DCMAKE_INSTALL_PREFIX=/usr \\\n";
        data += "        -DCMAKE_INSTALL_LIBDIR=/usr/lib64 ..\n";
        data += "}\n\n";
        data += "build () {\n";
        data += "    cd build\n";
        data += "    make $jobs\n";
        data += "}\n\n";
        data += "package () {\n";
        data += "    cd build\n";
        data += "    make install $jobs\n";

    }else if (buildtype == "meson") {
        data += "setup () {\n";
        data += "    meson setup build --prefix=/usr \\\n";
        data += "        --libdir=/usr/lib64/\n";
        data += "        -Ddefault_library=both\n";
        data += "}\n\n";
        data += "build () {\n";
        data += "    ninja -C build $jobs\n";
        data += "}\n\n";
        data += "package () {\n";
        data += "    ninja -C build install $jobs\n";

    }else {
        data += "setup () {\n";
        data += "    :\n";
        data += "}\n\n";
        data += "build () {\n";
        data += "    :\n";
        data += "}\n\n";
        data += "package () {\n";
        data += "    :\n";
    }
    data += "}\n\n";

    if (get_bool ("ask")) {
        print (colorize (_ ("Please check ympbuild:"), blue));
        print (data);
        if (!yesno (colorize (_ ("Is it OK ?"), red))) {
            return 1;
        };
    }
    string target=srealpath (str_or_def ("output", ""));
    error (1);
    print (colorize (_ ("Creating template: %s"), yellow).printf (target));
    create_dir (target);
    writefile (target + "/ympbuild", data);
    return 0;
}

private string get_gitconfig_variable (string variable) {
    string gitconfig = srealpath (GLib.Environment.get_variable ("HOME") + "/.gitconfig");
    if (isfile (gitconfig)) {
        info (_ ("Reading gitconfig: %s").printf (gitconfig));
        foreach (string line in readfile (gitconfig).split ("\n")) {
            if (variable + " =" in line) {
                return ssplit (line, "=")[1].strip ();
            }
        }
    }
    return "";
}

private string str_or_def (string val, string def) {
    string f = get_value (val);
    if (f != "") {
        return f;
    }
    if (def == "") {
        error_add (_ ("Variable '%s' is not defined. please use --%s").printf (val, val));
    }
    return def.strip ();
}

static void template_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (template_main);
    op.names = {_ ("template"), "template", "t"};
    op.help.name = _ ("template");
    op.help.description = _ ("Create ympbuild from template.");
    op.help.add_parameter ("--name", _ ("package name"));
    op.help.add_parameter ("--version", _ ("package version"));
    op.help.add_parameter ("--homepage", _ ("package homepage"));
    op.help.add_parameter ("--description", _ ("package description"));
    op.help.add_parameter ("--depends", _ ("package dependencies"));
    op.help.add_parameter ("--makedepends", _ ("package build dependencies"));
    op.help.add_parameter ("--email", _ ("package creator email"));
    op.help.add_parameter ("--maintainer", _ ("package maintainer"));
    op.help.add_parameter ("--license", _ ("package license"));
    op.help.add_parameter ("--source", _ ("package source"));
    op.help.add_parameter ("--build-type", _ ("package build-type (autotool cmake meson)"));
    op.help.add_parameter ("--output", _ ("ympbuild output directory"));
    add_operation (op);
}
