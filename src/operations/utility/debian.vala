private static int debian_main (string[] args) {
    string output = get_value ("output");
    if (output == "") {
        output=pwd ();
    }
    if (get_bool ("extract")) {
        foreach (string arg in args) {
            deb_extract (arg, output);
        }
    }else if (get_bool ("create")) {
        foreach (string arg in args) {
            deb_create (arg, output);
        }
    }

    if (get_bool ("update-catalog")) {
        debian_update_catalog ();
    }if (get_bool ("get-pkgname")) {
        foreach (string arg in args) {
            print (find_debian_pkgname_from_catalog (arg));
        }
    }

    if (get_bool ("install")) {
        set_bool ("convert", true);
    }if (get_bool ("convert")) {
        foreach (string arg in args) {
            debian_convert (srealpath (arg));
        }
    }
    return 0;
}

static void debian_init () {
    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (debian_main);
    op.names = {_ ("debian"), "deb", "debian"};
    op.help.name = _ ("debian");
    op.help.description = _ ("Debian package operations.");
    op.help.add_parameter (colorize (_ ("Package options"), magenta), "");
    op.help.add_parameter ("--extract", _ ("extract debian package"));
    op.help.add_parameter ("--create", _ ("create debian package"));
    op.help.add_parameter ("--convert", _ ("convert debian package to ymp package"));
    op.help.add_parameter (colorize (_ ("Install options"), magenta), "");
    op.help.add_parameter ("--install", _ ("install debian package") + colorize (colorize (colorize (" (%s)", red), 5), 1).printf (_ ("Dangerous")));
    op.help.add_parameter (colorize (_ ("Catalog options"), magenta), "");
    op.help.add_parameter ("--update-catalog", _ ("update debian catalog from debian repository"));
    op.help.add_parameter ("--get-pkgname", _ ("get source package name from catalog"));
    op.help.add_parameter ("--mirror", _ ("debian mirror url"));
    add_operation (op);
}
