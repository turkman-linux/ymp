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

array2* array2_new();
void array2_add(array2 *arr, char* data);
char **array2_get(array2 *arr, int* len);
size_t array2_length(array2 *arr);
void array2_reverse(array2 *arr);
void array2_sort(array2 *arr);
void array2_unref(array2 *arr);
void array2_remove(array2* arr, char* item);
