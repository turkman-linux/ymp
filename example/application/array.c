/* ymp header */
#include <ymp/array.h>
/* for printf */
#include <stdio.h>
/*
Build command:
     gcc `pkg-config --cflags --libs ymp` array.c -o array
*/

int main(int argc, char** argv){
    /* define array */
    array *a = array_new();
    /* add items */
    array_add(a,"hello");
    array_add(a,"world");
    array_add(a,"test");
    /* delete item */
    array_remove(a,"test");
    /* get all items */
    int len=0;
    char** arr = array_get(a,&len);
    /* print items */
    for(int i=0;i<len;i++){
        printf("%s\n",arr[i]);
    }
    return 0;
}