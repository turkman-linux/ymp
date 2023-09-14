public int get_main (string[] args) {
    if (args.length < 1) {
        foreach (string name in list_values ()) {
            print (name + ":" + get_value (name));
        }
        return 0;
    }
    var value = get_value (args[0]);
    if (value == "") {
        return 1;
    }
    print (value);
    return 0;
}

public int set_main (string[] args) {
    if (args.length < 2) {
        return 1;
    }
    set_value (args[0], args[1]);
    return 0;
}

public int read_main (string[] args) {
    if (args.length < 1) {
        return 1;
    }
    set_value (args[0], stdin.read_line ());
    return 0;
}

public int equal_main (string[] args) {
    if (args.length < 2) {
        return 1;
    }
    if (args[0] == args[1]) {
        return 0;
    }
    return 1;
}

public int match_main (string[] args) {
    if (args.length < 2) {
        return 1;
    }
    if (Regex.match_simple (args[0], args[1])) {
        return 0;
    }
    return 1;
}

public int cd_main (string[] args) {
    foreach (string arg in args) {
        cd (arg);
    }
    return 0;
}
public int export_main (string[] args) {
    foreach (string arg in args) {
        set_env(arg,get_value (arg));
    }
    return 0;
}

void setget_init () {
    operation op_get = new operation ();
    op_get.help = new helpmsg ();
    op_get.callback.connect (get_main);
    op_get.names = {_ ("get"), "get"};
    op_get.help.name = _ ("get");
    op_get.help.shell_only = true;
    op_get.help.description = _ ("Get variable from name.");

    operation op_set = new operation ();
    op_set.help = new helpmsg ();
    op_set.callback.connect (set_main);
    op_set.names = {_ ("set"), "set"} ;
    op_set.help.name = _ ("set");
    op_set.help.minargs=2;
    op_set.help.shell_only = true;
    op_set.help.description = _ ("Set variable from name and value.");

    operation op_equal = new operation ();
    op_equal.help = new helpmsg ();
    op_equal.callback.connect (equal_main);
    op_equal.names = {_ ("equal"), "equal", "eq"};
    op_equal.help.name = _ ("equal");
    op_equal.help.minargs=2;
    op_equal.help.shell_only = true;
    op_equal.help.description = _ ("Compare arguments equality.");

    operation op_read = new operation ();
    op_read.help = new helpmsg ();
    op_read.callback.connect (read_main);
    op_read.names = {_ ("read"), "read", "input"};
    op_read.help.name = _ ("read");
    op_read.help.minargs=1;
    op_read.help.shell_only = true;
    op_read.help.description = _ ("Read value from terminal.");

    operation op_match = new operation ();
    op_match.help = new helpmsg ();
    op_match.callback.connect (match_main);
    op_match.names = {_ ("match"), "match", "regex"};
    op_match.help.name = _ ("match");
    op_match.help.minargs=2;
    op_match.help.shell_only = true;
    op_match.help.description = _ ("Match arguments regex.");

    operation op_cd = new operation ();
    op_cd.help = new helpmsg ();
    op_cd.callback.connect (cd_main);
    op_cd.names = {_ ("cd"), "cd"};
    op_cd.help.name = _ ("cd");
    op_cd.help.shell_only = true;
    op_cd.help.description = _ ("Change directory.");

    operation op_exp = new operation ();
    op_exp.help = new helpmsg ();
    op_exp.callback.connect (export_main);
    op_exp.names = {_ ("export"), "export"};
    op_exp.help.name = _ ("export");
    op_exp.help.shell_only = true;
    op_exp.help.description = _ ("Convert value to environmental.");

    add_operation (op_get);
    add_operation (op_set);
    add_operation (op_equal);
    add_operation (op_read);
    add_operation (op_match);
    add_operation (op_cd);
    add_operation (op_exp);
}
