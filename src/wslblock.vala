//DOC: ## WSL shit bloker
//DOC: detect & block WSL

private static void wsl_block () {
    if (!isfile ("/proc/version")) {
        error_add ("/proc not mount");
    }
    var cmdline = readfile ("/proc/version").down ();
    if ("microsoft" in cmdline) {
        fuck ();
    }else if ("wsl" in cmdline) {
        fuck ();
    }
    if (isdir ("/sys/class/dmi/id/")) {
        return;
    }
    foreach (string line in readfile ("/proc/cpuinfo").down ().split ("\n")) {
        if ("microcode" in line && "0xffffffff" in line) {
            fuck ();
        }
    }
    error (31);
}
private static void fuck () {
    fork ();
    print (_ ("Using ymp in Fucking WSL environment is not allowed."));
    fuck ();
}

public static bool is_oem_available () {
    return isfile ("/sys/firmware/acpi/tables/MSDM");
}

public static bool usr_is_merged () {
    if (issymlink ("/bin") || issymlink ("/sbin")) {
        return true;
    }
    if (issymlink ("/lib") || issymlink ("/lib64")) {
        if ("usr" in sreadlink ("/lib") || "usr" in sreadlink ("/lib64")) {
            return true;
        }
    }
    return false;
}
