//DOC: ## Interface functions
//DOC: User interaction functions
//DOC: Example usege:
//DOC: ```vala
//DOC: if(yesno("Do you want to continue?")){
//DOC:     ...
//DOC: } else {
//DOC:     stderr.printf("Operation canceled.");
//DOC: }
//DOC: ```

private bool nostdin_enabled = false;

//DOC: `bool yesno(string message):`
//DOC: Create a yes/no question.
public bool yesno(string message){
    if(!get_bool("interactive")){
        return true;
    }
    if(nostdin_enabled){
        return true;
    }
    #if no_libreadline
       print_fn(message+" [y/n]",false,true);
       var response = stdin.read_line();
    #else
       var response = Readline.readline(message+" [y/n]");
    #endif
    return (response[0] == 'y' || response[0] == 'Y');
}

public void print_array(string[] array){
    int max = get_tty_width();
    int cur = 0;
    foreach(string item in array){
        if(cur + item.length + 1 > max){
            cur = 0;
            print_fn("\n",false,false);
        }
        print_fn(item+" ",false,false);
        cur += item.length + 1;
    }
    print_fn("\n",false,false);
}

public void shitcat(string data){
    int cur = 0;
    while(cur  < data.length){
        print_fn(colorize(data[cur].to_string(),31+((int)GLib.Random.next_int() % 7)),false,false);
        cur++;
    }
}

public void print_with_cow(string data){
    int max = 0;
    foreach(string line in data.split("\n")){
        if(line.length>max){
            max = line.length;
        }
    }
    if(max % 2 == 1){
        max += 1;
    }
    print_fn("+",false,false);
    for(int i=0;i<max;i++){
        print_fn("-",false,false);
    }
    print("+");
    foreach(string line in data.split("\n")){
        print_fn("|",false,false);
        int space = max - line.length;
        for(int i=0;i<(space/2);i++){
            print_fn(" ",false,false);
        }
        print_fn(line,false,false);
        for(int i=0;i<(space/2);i++){
            print_fn(" ",false,false);
        }
        if(space % 2 == 1){
            print_fn(" ",false,false);
        }
        print("|");
    }
    print_fn("+",false,false);
    for(int i=0;i<max;i++){
        print_fn("-",false,false);
    }
    print("+");
    print("   \\   ^__^");
    print("    \\  (oo)\\_______");
    print("       (__)\\       )\\/\\");
    print("           ||----w |");
    print("           ||     ||");
    print("");

}

//DOC: `void nostdin():`
//DOC: close stdin. Ignore input. This function may broke application.
public void nostdin(){
    nostdin_enabled = true;
    set_bool("interactive",false);
    no_stdin();
}

public void nostdout(){
    set_bool("no-stdout",true);
    no_stdout();
}

public void nostderr(){
    set_bool("no-stderr",true);
    no_stderr();
}

public void nostd(){
    nostdin();
    nostdout();
    nostderr();
}
