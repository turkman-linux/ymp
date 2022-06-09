#ifndef _nostd
#define _nostd

#include <stdio.h>
#include <unistd.h>

int devnull;
void no_stdin(){
    fclose(stdin);
}

void no_stdout(){
     devnull = fileno(fopen("/dev/null","r"));
     dup2(devnull, STDOUT_FILENO);
}

void no_stderr(){
    devnull = fileno(fopen("/dev/null","r"));
    dup2(devnull, STDERR_FILENO);
}

#endif
