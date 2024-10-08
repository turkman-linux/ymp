#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include <array.h>

#include <glib.h>

#define strdup(A) strcpy(calloc(strlen(A) + 1, sizeof(char)), A)

static int string_compare(const void* a, const void* b){
    return strcmp(*(const char**)a, *(const char**)b);
}

void csort(char* arr[], gint n){
    qsort(arr, n, sizeof(const char*), string_compare);
}

array *array_new() {
    array *arr = (array *)calloc(1,sizeof(array));
    arr->data = (char**)calloc(1024, sizeof(char*));
    arr->size = 0;
    arr->capacity = 1024;
    arr->removed = 0;
    arr->lock = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
    size_t start;
    for(start=0;start<arr->capacity;start++){
        arr->data[start] = NULL;
    }
    return arr;
}

void array_unref(array *arr) {
    free(arr);
}

void array_add(array *arr, char *value) {
    if(value == NULL){
        return;
    }
    pthread_mutex_lock(&arr->lock);
    if (arr->size >= arr->capacity-1) {
        arr->capacity += 1024;
        arr->data = (char **)realloc(arr->data, arr->capacity * sizeof(char *));
        size_t start;
        for(start=arr->capacity-1024;start<arr->capacity;start++){
            arr->data[start] = NULL;
        }
    }
    arr->size++;
    arr->data[arr->size]=strdup(value);
    pthread_mutex_unlock(&arr->lock);
}

void array_set(array *arr, char** new_data, size_t len){
    pthread_mutex_lock(&arr->lock);
    arr->data = calloc(arr->capacity, sizeof(char*));
    arr->size = 0;
    arr->removed = 0;
    size_t start;
    for(start=0;start<arr->capacity;start++){
            arr->data[start] = NULL;
    }
    pthread_mutex_unlock(&arr->lock);
    array_adds(arr, new_data, len);
}

char* array_get_string(array *arr){
    pthread_mutex_lock(&arr->lock);
    size_t tot_len = 0;
    size_t start = 0;
    while(start < arr->capacity){
        if(arr->data[start] != NULL){
            tot_len += strlen(arr->data[start]);
        }
        start++;
    }
    char* ret = calloc(tot_len+1, sizeof(char));
    start = 0;
    while(start < arr->size+arr->removed+1){
        if(arr->data[start] != NULL){
            strcat(ret, arr->data[start]);
        }
        start++;
    }
    pthread_mutex_unlock(&arr->lock);
    return ret;
}

void array_adds(array *arr, char **value, size_t len) {
    size_t i;
    for(i=0;i<len;i++){
        array_add(arr, value[i]);
    }
}

void array_remove(array* arr, char* item){
    pthread_mutex_lock(&arr->lock);
    size_t start = 0;
    while(start < arr->capacity){
        if(arr->data[start] != NULL && strcmp(arr->data[start],item)==0){
            arr->data[start] = NULL;
            arr->size -= 1;
            arr->removed +=1;
        }
        start++;
    }
    pthread_mutex_unlock(&arr->lock);
}

bool array_has(array* arr, char* name){
    pthread_mutex_lock(&arr->lock);
    size_t start = 0;
    while(start < arr->size + arr->removed){
        if(arr->data[start]){
           if (strcmp(arr->data[start], name) == 0){
               pthread_mutex_unlock(&arr->lock);
               return true;
           }
        }
        start++;
    }
    pthread_mutex_unlock(&arr->lock);
    return false;
}

void array_uniq(array* arr){
    pthread_mutex_lock(&arr->lock);
    size_t start = 1;
    size_t i = 0;
    size_t removed = 0;
    while(start < arr->capacity){
        if(arr->data[start] == NULL){
            start++;
            continue;
        }
        for(i=0;i<start-1;i++){
             if(arr->data[i] != NULL && strcmp(arr->data[i],arr->data[start])==0){
                 arr->data[i] = NULL;
                 removed++;
            }
        }
        start++;
    }
    arr->size -= removed;
    arr->removed = removed;
    pthread_mutex_unlock(&arr->lock);
}

void array_pop(array* arr, size_t index){
    pthread_mutex_lock(&arr->lock);
    arr->data[index] = NULL;
    arr->size -= 1;
    arr->removed +=1;
    pthread_mutex_unlock(&arr->lock);
}


void array_insert(array* arr, char* value, size_t index){
    pthread_mutex_lock(&arr->lock);
    if (arr->size >= arr->capacity) {
        array_add(arr,NULL);
    }
    if (arr->data[index] == NULL){
        arr->data[index] = value;
        arr->size++;
        pthread_mutex_unlock(&arr->lock);
        return;
    }
    char* tmp = strdup(arr->data[index]);
    char* tmp2;
    arr->data[index] = strdup(value);
    size_t start = index+1;
    while(start < arr->capacity){
        if(arr->data[start] == NULL){
            arr->data[start] = tmp;
            arr->size+=1;
            pthread_mutex_unlock(&arr->lock);
            return;
        }
        tmp2 = strdup(arr->data[start]);
        arr->data[start] = strdup(tmp);
        tmp = strdup(tmp2);
        start++;
    }
    arr->size += 1;
    pthread_mutex_unlock(&arr->lock);
}

void array_sort(array* arr){
    pthread_mutex_lock(&arr->lock);
    char** new_data = (char**)calloc(arr->capacity,sizeof(char*));
    size_t start = 0;
    size_t skip = 0;
    while(start < arr->size+arr->removed+1){
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
    pthread_mutex_unlock(&arr->lock);
}

char **array_get(array *arr, int* len) {
    pthread_mutex_lock(&arr->lock);
    *len = arr->size;
    char** ret = calloc(arr->size+1, sizeof(char*));
    size_t start = 0;
    size_t skip = 0;
    while(start < arr->size+arr->removed+1 && start < arr->capacity){
        if(arr->data[start] == NULL){
            start++;
            skip++;
            continue;
        }
        ret[start-skip]=strdup(arr->data[start]);
        start++;
    }
    pthread_mutex_unlock(&arr->lock);
    return ret;
}

size_t array_length(array *arr) {
    return arr->size-arr->removed;
}


void array_reverse(array *arr) {
    pthread_mutex_lock(&arr->lock);
    if (arr->size <= 1) {
        pthread_mutex_unlock(&arr->lock);
        return; /* No need to reverse if size is 0 or 1 */
    }

    size_t start = 0;
    size_t tot = arr->size + arr->removed;
    while (start < tot/2) {
        /* Swap elements at start and end indices */
        char *temp = arr->data[start];
        char* temp2 = arr->data[tot-start-1];
        if(temp2 != NULL){
            arr->data[start] = strdup(temp2);
        }
        if(temp != NULL){
            arr->data[tot-start-1] = strdup(temp);
        }else{
            arr->data[tot-start-1] = NULL;
        }

        /* Move towards the center */
        start++;
    }
    pthread_mutex_unlock(&arr->lock);
}
