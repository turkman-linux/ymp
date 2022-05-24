logger log;
public class Inary {
    public inaryconfig config;
    public logger log;
}
public Inary inary_init(){
    ctx_init();
    Inary app = new Inary();
    app.log = new logger();
    app.config = settings_init();
    app.log.enable_debug = (app.config.debug == "true");
    log = new logger();
    return app;
}
