#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define strdup(A) strcpy(calloc(strlen(A) + 1, sizeof(char)), A);

static size_t i;
static size_t start, skip, removed;
static char* tmp;
static char* tmp2;

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
    arr->data = (char**)calloc(1024, sizeof(char*));
    arr->size = 0;
    arr->capacity = 1024;
    return arr;
}

void array2_unref(array2 *arr) {
    free(arr);
}

void array2_add(array2 *arr, char *value) {
    if (arr->size >= arr->capacity) {
        arr->capacity += 1024;
        arr->data = (char **)realloc(arr->data, arr->capacity * sizeof(char *));
    }
    if(value == NULL){
        arr->size++;
        return;
    }
    start = 0;
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

void array2_set(array2 *arr, char** new_data, size_t len){
    arr->data = new_data;
    arr->size = len;
}

char* array2_get_string(array2 *arr){
    size_t tot_len = 0;
    start = 0;
    while(start < arr->capacity){
        if(arr->data[start] != NULL){
            tot_len += strlen(arr->data[start]);
        }
        start++;
    }
    char* ret = calloc(tot_len+1, sizeof(char));
    start = 0;
    while(start < arr->capacity){
        if(arr->data[start] != NULL){
            strcat(ret, arr->data[start]);
        }
        start++;
    }
    return ret;
}

void array2_adds(array2 *arr, char **value, size_t len) {
    for(i=0;i<len;i++){
        array2_add(arr,value[i]);
    }
}

void array2_remove(array2* arr, char* item){
    start = 0;
    while(start < arr->capacity){
        if(arr->data[start] != NULL && strcmp(arr->data[start],item)==0){
            arr->data[start] = NULL;
            arr->size -= 1;
        }
        start++;
    }
}

bool array2_has(array2* arr, char* name){
    start = 0;
    while(start < arr->capacity){
        if (arr->data[start] != NULL && strcmp(arr->data[start],name) == 0){
            return true;
        }
        start++;
    }
    return false;
}

void array2_uniq(array2* arr){
    start = 1;
    i = 0;
    removed = 0;
    while(start < arr->capacity){
         for(i=0;i<start-1;i++){
             if(arr->data[i] != NULL && strcmp(arr->data[i],arr->data[start])==0){
                 arr->data[i] = NULL;
                 removed++;
            }
        }
        start++;
    }
    arr->size -= removed;
}

void array2_pop(array2* arr, size_t index){
    arr->data[index] = NULL;
    arr->size -= 1;
}


void array2_insert(array2* arr, char* value, size_t index){
    if (arr->size >= arr->capacity) {
        array2_add(arr,NULL);
    }
    if (arr->data[index] == NULL){
        arr->data[index] = value;
        arr->size++;
        return;
    }
    tmp = strdup(arr->data[index]);
    arr->data[index] = strdup(value);
    size_t start = index+1;
    while(start < arr->capacity){
        if(arr->data[start] == NULL){
            arr->data[start] = tmp;
            arr->size+=1;
            return;
        }
        tmp2 = strdup(arr->data[start]);
        arr->data[start] = strdup(tmp);
        tmp = strdup(tmp2);
        start++;
    }
    arr->size += 1;
}

void array2_sort(array2* arr){
    char** new_data = (char**)calloc(arr->capacity,sizeof(char*));
    start = 0;
    skip = 0;
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
    start = 0;
    skip = 0;
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

    start = 0;

    while (start < arr->capacity/2) {
        /* Swap elements at start and end indices */
        char *temp = arr->data[start];
        arr->data[start] = arr->data[arr->capacity-start-1];
        arr->data[arr->capacity-start-1] = temp;

        /* Move towards the center */
        start++;
    }
}
