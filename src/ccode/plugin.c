#ifndef _plugin
#define _plugin
#include <stdio.h>
#include <dlfcn.h>
void load_plugin(char* path){
    void *handle;
    handle = dlopen(path, RTLD_LAZY);
    if (!handle) {
        fprintf(stderr, "Failed to load plugin: %s from %s\n ",dlerror(), path);
        return;
    }
    dlerror();
    void (*plugin_func)();
    *(void**)(&plugin_func) = dlsym(handle, "plugin_init");
    plugin_func();
    dlclose(handle);
}
#endif
