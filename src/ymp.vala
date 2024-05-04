private bool ymp_activated = false;

#ifndef no_locale
private extern void locale_init();
public const string GETTEXT_PACKAGE="ymp";
#endif
public void ymp_init (string[] args) {
    if(ymp_activated){
        return;
    }
    #ifndef no_locale
    locale_init();
    #endif
    c_umask (022);
    // initial load
    parse_args(args);
    logger_init();
    settings_init ();
    wsl_block ();
    ctx_init ();
    // override settings
    parse_args(args);
    #if SHARED
    info (_ ("Plugin manager init"));
    foreach (string lib in find (DISTRODIR)) {
        string libname = sbasename (lib);
        if (startswith (libname, "libymp_") && endswith (libname, ".so")) {
            info (_ ("Load plugin: %s").printf (libname));
            load_plugin (lib);
        }
    }
    #endif
    directories_init ();
    #if check_oem
        if (is_oem_available ()) {
            warning (_ ("OEM detected! Ymp may not working good."));
            #if experimental
            if(true) {
            #else
            if (!get_bool ("ALLOW-OEM") && ! isfile("/.allow-oem")) {
            #endif
                error_add (_ ("OEM is not allowed! Please use --allow-oem to allow oem."));
                error_add (_ ("If you wish to bypass this error entirely, create /.allow-oem empty file."));
            }
        }
    if (usr_is_merged ()) {
        warning (_ ("UsrMerge detected! Ymp may not working good."));
    }
    #endif
    if (has_error ()) {
        error (31);
    }
    ymp_activated = true;
}

private void directories_init () {
    create_dir (get_build_dir ());
    GLib.FileUtils.chmod (get_build_dir (), 0777);
    create_dir (get_storage () + "/index/");
    create_dir (get_storage () + "/packages/");
    create_dir (get_storage () + "/metadata/");
    create_dir (get_storage () + "/files/");
    create_dir (get_storage () + "/links/");
    create_dir (get_storage () + "/gpg/");
    create_dir (get_storage () + "/sources.list.d/");
    create_dir (get_storage () + "/quarantine/");
    if (!isfile (get_storage () + "/sources.list")) {
        writefile (get_storage () + "/sources.list", "");
    }
    #if experimental
    if (is_root ()) {
        foreach (string path in find (get_storage ())) {
            chmod (path, 0755);
            chown (path, 0, 0);
        }
    }
    #endif
    GLib.FileUtils.chmod (get_storage () + "/gpg/", 0700);
}
