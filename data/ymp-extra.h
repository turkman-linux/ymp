#ifndef _ymp_extra
#define _ymp_extra
#include <stdbool.h>

#define try bool __HadError=false;
#define catch(x) ExitJmp:if(__HadError)
#define throw(x) {__HadError=true;goto ExitJmp;}

#endif

/* array library */
typedef struct {
    char **data;
    size_t size;
    size_t capacity;
} array2;

void array2_add(array2 *arr, char* data);
char *array2_get(array2 *arr, size_t index);
size_t array2_length(array2 *arr);