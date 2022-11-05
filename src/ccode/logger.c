#include <stdio.h>
#include <string.h>

void print_fn(char* message, int new_line, int err){
    if(strcmp(message,"")==0){
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
    fputs(message,stdout);
    fputc('\n',stdout);
    fflush(stdout);
}
void cprint_stderr(char* message){
    fputs(message,stderr);
    fputc('\n',stderr);
    fflush(stderr);
}

void cprint_dummy(char* message){}
