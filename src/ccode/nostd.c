#ifndef _nostd
#define _GNU_SOURCE
#define _nostd

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

int saved_stdout = -1;
int saved_stderr = -1;

int devnull;
void no_stdin(){
    fclose(stdin);
}

void no_stdout(){
    if(saved_stdout == -1){
        saved_stdout = dup(1);
    }
    devnull = open("/dev/null", O_WRONLY);
    dup2(devnull, STDOUT_FILENO);
}

void no_stderr(){
    if(saved_stderr == -1){
        saved_stderr = dup(2);
    }
    devnull = open("/dev/null", O_WRONLY);
    dup2(devnull, STDERR_FILENO);
}

void reset_std(){
    if(saved_stderr != -1){
        dup2(saved_stderr, STDERR_FILENO);
    }
    if(saved_stdout != -1){
        dup2(saved_stdout, STDOUT_FILENO);
    }
}

#endif
