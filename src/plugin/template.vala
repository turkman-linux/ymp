/* This is template ymp plugin.

  For build plugin you must run this command:
     valac template.vala --pkg ymp --library=libymp_template.so \
         -X -shared -o libymp_template.so
*/
// Plugins require plugin_init function like this
public void plugin_init(){
    // All plugins loaded after ctx_init function.
    info("Hello World");
}
