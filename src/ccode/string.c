#ifndef _string
#define _string
#include <stddef.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>

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

#endif
