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
    size_t i;
    for (i = 0; i < arr->size; i++) {
        free(arr->data[i]);
    }
    free(arr->data);
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

char *array2_get(array2 *arr, size_t index) {
    if (index < arr->size) {
        return arr->data[index];
    } else {
        return NULL;
    }
}

size_t array2_length(array2 *arr) {
    return arr->size;
}

