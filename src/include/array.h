typedef struct {
    char **data;
    size_t size;
    size_t capacity;
} array2;

array2* array2_new();
void array2_add(array2 *arr, char* data);
void array2_adds(array2 *arr, char** data, size_t len);
char **array2_get(array2 *arr, int* len);
char *array2_get_string(array2 *arr);
size_t array2_length(array2 *arr);
void array2_reverse(array2 *arr);
void array2_uniq(array2 *arr);
void array2_insert(array2 *arr, char* value, size_t index);
void array2_sort(array2 *arr);
void array2_unref(array2 *arr);
void array2_remove(array2* arr, char* item);

