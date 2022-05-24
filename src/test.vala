logger log;
void main(){
    log = new logger();
    log.error_add("Hello World");
    #if DEBUG
    log.error_add("Test 123");
    #endif
    log.error(0);
    log.error(1);
}
