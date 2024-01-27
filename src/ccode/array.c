#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define strdup(A) strcpy(calloc(strlen(A) + 1, sizeof(char)), A);

typedef struct {
    char **data;
    size_t size;
    size_t capacity;
} array2;

array2 *array2_new() {
    array2 *arr = (array2 *)calloc(1,sizeof(array2));
    arr->size = 0;
    arr->capacity = 0;
    return arr;
}

void array2_unref(array2 *arr) {
    free(arr);
}

void array2_add(array2 *arr, const char *value) {
    if (arr->size >= arr->capacity) {
        arr->capacity += 1;
        arr->data = (char **)realloc(arr->data, arr->capacity * sizeof(char *));
    }

    arr->data[arr->size] = strdup(value);
    arr->size++;
}

char **array2_get(array2 *arr, int* len) {
    *len = arr->size;
    return arr->data;
}

size_t array2_length(array2 *arr) {
    return arr->size;
}

void array2_reverse(array2 *arr) {
    if (arr->size <= 1) {
        return; /* No need to reverse if size is 0 or 1 */
    }

    size_t start = 0;

    while (start < arr->size/2) {
        /* Swap elements at start and end indices */
        char *temp = arr->data[start];
        arr->data[start] = arr->data[arr->size-start-1];
        arr->data[arr->size-start-1] = temp;

        /* Move towards the center */
        start++;
    }
}
