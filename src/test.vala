logger log;
void main(){
    log = new logger();
    log.error_add("Hello World");
    #if DEBUG
    log.error_add("Test 123");
    #endif
    string i = getoutput("echo -n hmmm");
    log.debug(i.to_string());
    log.debug(run_silent("non-command -non-parameter").to_string());
    run("non-command -non-parameter");
    log.error(0);
    log.error(1);
}
