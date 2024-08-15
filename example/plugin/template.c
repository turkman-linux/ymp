/* This is template ymp plugin.

  For build plugin you must run this command:
     gcc template.c `pkg-config --cflags --libs ymp` -shared \
         -o libymp_template.so
*/

#include <ymp.h>

// Plugins require plugin_init function like this
void plugin_init(){
    // All plugins loaded after ctx_init function.
    info("Hello World",NULL);
}
