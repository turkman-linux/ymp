#include <stddef.h>
#include <stdlib.h>

#if defined(__x86_64__)
void* g_malloc(size_t size){
    return (void*) calloc((size_t)1, size);
}

void* malloc(size_t size){
    return (void*) calloc((size_t)1, size);
}
#endif