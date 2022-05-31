//DOC: ## Interface functions
//DOC: User interaction functions;
//DOC: Example usege:;
//DOC: ```vala
//DOC: if(yesno("Do you want to continue?")){ 
//DOC:     ... 
//DOC: } else { 
//DOC:     stderr.printf("Operation canceled."); 
//DOC: } 
//DOC: ```;

//DOC: `bool yesno(string message):`
//DOC: Create a yes/no question.
public bool yesno(string message){
    if(!get_bool("interactive")){
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
