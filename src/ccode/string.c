#ifndef _string
#define _string
#include <stddef.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>

#ifndef get_bool
char* get_value(char* variable);
#endif

char long_buffer[1024*1024*1024];
char medium_buffer[1024*1024];

char* build_string(char* format, ...){
    strcpy(medium_buffer,"");
    va_list args;
    va_start (args, format);
    vsnprintf (medium_buffer, (1024*1024)-1, format, args);
    va_end (args);
    return medium_buffer;

}
int run_printf(char* format, ...){
    char cmd[1024];
    va_list args;
    va_start (args, format);
    vsnprintf (cmd, 1023, format, args);
    va_end (args);
    fprintf(stderr,"%s\n",cmd);
    return system(cmd);

}

int iseq(char* str1, char* str2){
    return strcmp(str1,str2) == 0;
}
#ifndef NOCOLOR
char* ccolorize(char* msg, char* num){
    if(iseq(get_value("no-color"),"true")){
        return msg;
    }
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
