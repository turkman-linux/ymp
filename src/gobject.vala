namespace ymp_gobject {
    private Ymp ymp;
    public void init(string[] args){
        ymp = ymp_init(args);
    }
    public void add_process(string name, string[] args){
        ymp.add_process(name,args);
    }
    public void run(){
        ymp.run();
    }
}
