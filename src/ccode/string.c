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
#ifndef NOCOLOR
char* ccolorize(char* msg, char* num){
    char* ret = malloc((strlen(msg)+strlen(num))*(sizeof(char)+13));
    strcpy(ret,"\x1b[");
    strcat(ret,num);
    strcat(ret,"m");
    strcat(ret,msg);
    strcat(ret,"\x1b[0m");
    return ret;
}
#else
char* ccolorize(char* msg, char* num){
    return msg;
}
#endif

#endif
