#ifndef _plugin
#define _plugin
#include <stdio.h>
#include <dlfcn.h>

#include <error.h>

void load_plugin(char* path){
    void *handle;
    handle = dlopen(path, RTLD_LAZY);
    if (!handle) {
        ferror_add("Failed to load plugin: %s from %s\n ",dlerror(), path);
        return;
    }
    dlerror();
    void (*plugin_func)();
    *(void**)(&plugin_func) = dlsym(handle, "plugin_init");
    plugin_func();
    dlclose(handle);
}
#endif
