//DOC: ## Interface functions
//DOC: User interaction functions
//DOC: Example usege:
//DOC: ```vala
//DOC: if (yesno ("Do you want to continue?")) {
//DOC:     ...
//DOC: } else {
//DOC:     stderr.printf ("Operation canceled.");
//DOC: }
//DOC: ```

private bool nostdin_enabled = false;

//DOC: `bool yesno (string message):`
//DOC: Create a yes/no question.
public bool yesno (string message) {
    if (!get_bool ("ask")) {
        return true;
    }
    if (nostdin_enabled) {
        return false;
    }
    #if no_libreadline
       print_fn (_ ("%s [y/n]").printf (message), false, true);
       var response = stdin.read_line ();
    #else
       var response = Readline.readline (_ ("%s [y/n]").printf (message));
    #endif
    if (response == null || response == "") {
        return false;
    }
    return (response[0] == 'y' || response[0] == 'Y' \
        || response[0] == _("Yy")[0] || response[0] == _("Yy")[1]);
}

//DOC: `void print_array (string[] array):`
//DOC: print string array to fit terminal size
public void print_array (string[] array) {
    int max = get_tty_width ();
    int cur = 0;
    foreach (string item in array) {
        if (cur + item.length + 1 > max) {
            cur = 0;
            print_fn ("\n", false, false);
        }
        print_fn (item + " ", false, false);
        cur += item.length + 1;
    }
    print_fn ("\n", false, false);
}

//DOC: `void shitcat (string data):`
//DOC: print data with shitty random colors.
public void shitcat (string data) {
    int cur = 0;
    while (cur < data.length) {
        print_fn (colorize (data[cur].to_string (), 31 + ( (int)GLib.Random.next_int () % 7)), false, false);
        cur++;
    }
}

//DOC: `void print_with_amogus (string data):`
//DOC: print message with cow dialog
public void print_with_amogus (string data) {
    int max = 0;
    foreach (string line in data.split ("\n")) {
        if (line.length > max) {
            max = line.length;
        }
    }
    max += 2;
    if (max % 2 == 1) {
        max += 1;
    }
    print_fn (" + ", false, false);
    for (int i=0;i < max;i++) {
        print_fn ("-", false, false);
    }
    print (" + ");
    foreach (string line in data.split ("\n")) {
        print_fn ("|", false, false);
        int space = max - line.length;
        for (int i=0;i < (space / 2);i++) {
            print_fn (" ", false, false);
        }
        print_fn (line, false, false);
        for (int i=0;i < (space / 2);i++) {
            print_fn (" ", false, false);
        }
        if (space % 2 == 1) {
            print_fn (" ", false, false);
        }
        print ("|");
    }
    print_fn (" + ", false, false);
    for (int i=0;i < max;i++) {
        print_fn ("-", false, false);
    }
    print("");
    foreach(string line in ssplit(get_amogus(),"\n")){
        for(int i=0;i < (max / 3);i++){
            print_fn(" ",false,false);
        }
        print(line);
    }

}
