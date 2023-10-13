#ifndef _string
#define _string
#include <stddef.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>

int iseq(char* str1, char* str2){
    return strcmp(str1,str2) == 0;
}

static int string_compare(const void* a, const void* b){

    return strcmp(*(const char**)a, *(const char**)b);
}

void csort(const char* arr[], int n){
    qsort(arr, n, sizeof(const char*), string_compare);
}

long count_tab(char* data){
    long cnt=0;
    for(long i=0; data[i]==' '; i++) {
        cnt++;
    }
    return cnt;
}

char* join(char* f, char** array){
    size_t len = 0;
    int i = 0;
    int c = 0;
    // find output size
    while(array[i]){
        len += strlen(array[i]) + strlen(f);
        i++;
    }
    // allocate memory
    char* ret = malloc(sizeof(char)*len+1);
    strcpy(ret,"");
    // copy item len and reset value
    c = i;
    i = 0;
    // copy items
    while(array[i]){
        strcat(ret,array[i]);
        if(i<c-1){
            strcat(ret,f);
        }
	i++;
    }
    return ret;
}

char* str_add(char* str1, char* str2){
    char* ret = malloc( (strlen(str1)+strlen(str2)+1)*sizeof(char) );
    strcpy(ret,str1);
    strcat(ret,str2);
    return ret;
}

char* trim(char* data) {
    long i=0, j= 0, cnt=0;
    long len = strlen(data);
    char* str = malloc(len*sizeof(char)+1);
    strcpy(str,data);
    cnt = count_tab (data);
    j=cnt-1;
    for(i=0; i<len; i++) {
        j += 1;
        if(j >= len || str[i] == '\0') {
            str[i] = '\0';
            break;
        }
        str[i] = data[j];
        if(str[i] == '\n'){
            j += cnt;

        }
    }
    return str;
}
char* int_to_string(int num){
    char *ret = malloc(sizeof(char)*((sizeof(num) - 1) / 3 + 2));
    sprintf(ret, "%d", num);
    return ret;
}

#endif
