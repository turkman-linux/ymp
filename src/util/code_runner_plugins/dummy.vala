code_runner_plugin dummy;


public void code_runner_dummy_init(){
    dummy = new code_runner_plugin();
    dummy.name = "dummy";
    dummy.init.connect((image,dir)=>{});
    dummy.run.connect((command)=>{return 0;});
    dummy.clean.connect(()=>{});
    add_code_runner_plugin(dummy);
}
