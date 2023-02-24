#ifndef _plugin
#define _plugin
#include <dlfcn.h>
#ifndef warning
void warning(char* str);
#endif
void load_plugin(char* path){
    void *handle;
    handle = dlopen(path, RTLD_LAZY);
    if (!handle) {
        warning(dlerror());
        return;
    }
    dlerror();
    void (*plugin_func)();
    *(void**)(&plugin_func) = dlsym(handle, "plugin_init");
    plugin_func();
    dlclose(handle);
}
#endif
