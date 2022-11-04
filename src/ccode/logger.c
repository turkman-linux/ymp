#include <stdio.h>
#ifndef iseq
int iseq(char* str1, char* str2);
#endif

#ifndef true
#define true 1
#define false 0
#endif

void print_fn(char* message, int new_line, int err){
    if(iseq(message,"")){
        return;
    }
    FILE *fd=stdout;
    if(err){
        fd=stderr;
    }
    fprintf(fd,message);
    if(new_line){
        fputc('\n',fd);
    }
    fflush(fd);
}
void cprint(char* message){
    print_fn(message,true,false);
}
void cprint_stderr(char* message){
    print_fn(message,true,true);
}

void cprint_dummy(char* message){}
