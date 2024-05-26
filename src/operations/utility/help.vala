public static int help_main (string[] args) {
    if (args.length == 0) {
        print (colorize (_ ("Operation list:"), blue));
        foreach (operation op in ops) {
            if (!op.help.shell_only) {
                print_fn (colorize (op.help.name + " : ", green) + op.help.description + "\n", false, false);
            }
        }
        if (get_bool ("all")) {
            print (colorize (_ ("Shell only operation list:"), blue));
            foreach (operation op in ops) {
                if (op.help.shell_only) {
                    print_fn (colorize (op.help.name + " : ", green) + op.help.description + "\n", false, false);
                }
            }
        }
    }else {
        foreach (string arg in args) {
            foreach (operation op in ops) {
                if (arg in op.names) {
                    print (colorize (_ ("Aliases:"), green) + join (" / ", uniq (op.names)));
                    write_op_help (op);
                }
            }
        }

    }
    return 0;
}

public static void write_version () {
    print ("YMP : " + colorize ("Y", red) + "erli ve " + colorize ("M", red) + "illi " + colorize ("P", red) + "ackage manager");
    print (_ ("Version") + " : " + VERSION);
    if (!get_bool ("flag")) {
        return;
    }
    print ("");
    string flag = get_flag();
    foreach (string line in ssplit (flag, "\n")) {
        print ("    " + line);
    }
    print ("");
}

private static void write_op_help (operation op) {
    print_stderr (op.help.build ());
}


static void help_init () {
    add_common_parameter ("--", _ ("stop argument parser"));
    #if check_oem
    add_common_parameter ("--allow-oem", _ ("disable oem check"));
    #endif
    add_common_parameter ("--quiet", _ ("disable output"));
    add_common_parameter ("--ignore-warning", _ ("disable warning messages"));
    #if DEBUG
    add_common_parameter ("--debug", _ ("enable debug output"));
    #endif
    add_common_parameter ("--verbose", _ ("show verbose output"));
    add_common_parameter ("--ask", _ ("enable questions"));
    add_common_parameter ("--no-color", _ ("disable color output"));
    add_common_parameter ("--no-sysconf", _ ("disable sysconf triggers"));
    add_common_parameter ("--sandbox", _ ("run ymp actions at sandbox environment"));
    add_common_parameter ("--help", _ ("write help messages"));


    operation op = new operation ();
    op.help = new helpmsg ();
    op.callback.connect (help_main);
    op.names = {_ ("help"), "help"};
    op.help.name = _ ("help");
    op.help.description = _ ("Write help message about ymp commands.");
    add_operation (op);

}

private string[] common_parameters;
private void add_common_parameter (string arg, string desc) {
    if (common_parameters == null) {
        common_parameters = {};
    }
    common_parameters += (colorize (arg, red) + " : " + desc);
}

private class helpmsg {
    public string description="";
    private string[] parameters;
    public string name="";
    public string usage="";
    public int minargs = 0;
    public bool shell_only = false;

    public void add_parameter (string arg, string desc) {
        if (parameters == null) {
            parameters = {};
        }
        string f = (colorize (arg, red) + " : " + desc);
        parameters += f;
    }
    public string build () {
        string ret = "";
        if (usage == "") {
            usage = "ymp " + name + _ (" [OPTION]... [ARGS]... ");
        }
        ret += colorize (_ ("Usage:"), green) + " " + usage + "\n";
        ret += description + "\n";
        if (parameters.length > 0) {
            ret += colorize (_ ("Options:") + "\n", green);
            foreach (string param in parameters) {
                ret += "  " + param + "\n";
            }
        }
        ret += colorize (_ ("Common options:") + "\n", green);
        foreach (string param in common_parameters) {
            ret += "  " + param + "\n";
        }
        return ret;
    }
}
