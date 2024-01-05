private static int get_main (string[] args) {
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

private static int set_main (string[] args) {
    if (args.length < 2) {
        return 1;
    }
    set_value (args[0], args[1]);
    return 0;
}

private static int read_main (string[] args) {
    if (args.length < 1) {
        return 1;
    }
    set_value (args[0], stdin.read_line ());
    return 0;
}

private static int equal_main (string[] args) {
    if (args.length < 2) {
        return 1;
    }
    if (args[0] == args[1]) {
        return 0;
    }
    return 1;
}

private static int match_main (string[] args) {
    if (args.length < 2) {
        return 1;
    }
    if (Regex.match_simple (args[0], args[1])) {
        return 0;
    }
    return 1;
}

private static int cd_main (string[] args) {
    foreach (string arg in args) {
        cd (arg);
    }
    return 0;
}
private static int export_main (string[] args) {
    foreach (string arg in args) {
        set_env(arg,get_value (arg));
    }
    return 0;
}

private static int lt_main (string[] args) {
    if(double.parse(args[0]) >= double.parse(args[1])){
        return 1;
    }
    return 0;
}
private static int gt_main (string[] args) {
    if(double.parse(args[0]) <= double.parse(args[1])){
        return 1;
    }
    return 0;
}

private static int calc_main (string[] args) {
    double num1 = double.parse(args[1]);
    string operator = args[2];
    double num2 = double.parse(args[3]);
    if (operator == "+") {
        set_value(args[0], (num1 + num2).to_string());
    } else if (operator == "-") {
        set_value(args[0], (num1 - num2).to_string());
    } else if (operator == "*") {
        set_value(args[0], (num1 * num2).to_string());
    } else if (operator == "/") {
        set_value(args[0], (num1 / num2).to_string());
    }
    return 0;
}

private static int not_main (string[] args) {
    int status = operation_main(args[0], args[1:]);
    if(status == 0){
        return 1;
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

    operation op_lt = new operation ();
    op_lt.help = new helpmsg ();
    op_lt.callback.connect (lt_main);
    op_lt.names = {_ ("lt"), "lt", "<"};
    op_lt.help.minargs=2;
    op_lt.help.name = _ ("lt");
    op_lt.help.shell_only = true;
    op_lt.help.description = _ ("return true if first number lower than second");

    operation op_gt = new operation ();
    op_gt.help = new helpmsg ();
    op_gt.callback.connect (gt_main);
    op_gt.names = {_ ("gt"), "gt", ">"};
    op_gt.help.minargs=2;
    op_gt.help.name = _ ("gt");
    op_gt.help.shell_only = true;
    op_gt.help.description = _ ("return true if first number greater than second");

    operation op_calc = new operation ();
    op_calc.help = new helpmsg ();
    op_calc.callback.connect (calc_main);
    op_calc.names = {_ ("calc"), "calc", "="};
    op_calc.help.minargs=4;
    op_calc.help.name = _ ("calc");
    op_calc.help.shell_only = true;
    op_calc.help.description = _ ("calculator");

    operation op_not = new operation ();
    op_not.help = new helpmsg ();
    op_not.callback.connect (not_main);
    op_not.help.minargs=1;
    op_not.names = {_ ("not"), "not", "!"};
    op_not.help.name = _ ("not");
    op_not.help.shell_only = true;
    op_not.help.description = _ ("logic not");

    add_operation (op_get);
    add_operation (op_set);
    add_operation (op_equal);
    add_operation (op_read);
    add_operation (op_match);
    add_operation (op_cd);
    add_operation (op_exp);
    add_operation (op_lt);
    add_operation (op_gt);
    add_operation (op_calc);
    add_operation (op_not);
}
