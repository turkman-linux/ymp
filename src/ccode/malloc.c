#include <stddef.h>
#include <stdlib.h>
void* g_malloc(size_t size){
    return (void*) calloc((size_t)1, size);
}

void* malloc(size_t size){
    return (void*) calloc((size_t)1, size);
}
