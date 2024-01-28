#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define strdup(A) strcpy(calloc(strlen(A) + 1, sizeof(char)), A);


static int string_compare(const void* a, const void* b){
    return strcmp(*(const char**)a, *(const char**)b);
}

void csort(char* arr[], int n){
    qsort(arr, n, sizeof(const char*), string_compare);
}

typedef struct {
    char **data;
    size_t size;
    size_t capacity;
} array2;

array2 *array2_new() {
    array2 *arr = (array2 *)calloc(1,sizeof(array2));
    arr->data = (char*)calloc(1024, sizeof(char*));
    arr->size = 0;
    arr->capacity = 1024;
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
    size_t start = 0;
    while(start < arr->capacity){
        if(arr->data[start] == NULL){
            arr->data[start] = strdup(value);
            arr->size++;
            return;
        }
        start++;
    }
    arr->data[arr->size] = strdup(value);
    arr->size++;
}

void array2_remove(array2* arr, char* item){
    size_t start = 0;
    while(start < arr->capacity){
        if(arr->data[start] != NULL && strcmp(arr->data[start],item)==0){
            arr->data[start] = NULL;
            arr->size -= 1;
        }
        start++;
    }
}

void array2_sort(array2* arr){
    char** new_data = (char**)calloc(arr->capacity,sizeof(char*));
    size_t start = 0;
    size_t skip = 0;
     while(start < arr->capacity){
        if(arr->data[start] == NULL){
            start++;
            skip++;
            continue;
        }
        new_data[start-skip]=strdup(arr->data[start]);
        start++;
    }
    csort(new_data, arr->size);
    arr->data = new_data;
}

char **array2_get(array2 *arr, int* len) {
    *len = arr->size;
    char** ret = calloc(arr->size, sizeof(char*));
    size_t start = 0;
    size_t skip = 0;
    while(start < arr->capacity){
        if(arr->data[start] == NULL){
            start++;
            skip++;
            continue;
        }
        ret[start-skip]=strdup(arr->data[start]);
        start++;
    }
    return ret;
}

size_t array2_length(array2 *arr) {
    return arr->size;
}


void array2_reverse(array2 *arr) {
    if (arr->size <= 1) {
        return; /* No need to reverse if size is 0 or 1 */
    }

    size_t start = 0;

    while (start < arr->capacity/2) {
        /* Swap elements at start and end indices */
        char *temp = arr->data[start];
        arr->data[start] = arr->data[arr->capacity-start-1];
        arr->data[arr->capacity-start-1] = temp;

        /* Move towards the center */
        start++;
    }
}
