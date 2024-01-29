#include <stdbool.h>
#include <stddef.h>

typedef struct {
    char **data;
    size_t size;
    size_t capacity;
} array;

array* array_new();
void array_add(array *arr, char* data);
void array_adds(array *arr, char** data, size_t len);
char **array_get(array *arr, int* len);
char *array_get_string(array *arr);
size_t array_length(array *arr);
void array_reverse(array *arr);
void array_uniq(array *arr);
void array_insert(array *arr, char* value, size_t index);
void array_sort(array *arr);
void array_unref(array *arr);
bool array_has(array *arr, char* item);
void array_remove(array* arr, char* item);

