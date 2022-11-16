#ifndef _process
#define _process
#define _GNU_SOURCE
#include <sys/file.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/time.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <unistd.h>


#ifndef which
char* which(char* path);
#endif


int locked=0;
void single_instance(){
    if(locked){
        return;
    }
    int pid_file = open("/run/ymp.pid", O_CREAT | O_RDWR, 0666);
    int rc = flock(pid_file, LOCK_EX | LOCK_NB);
    locked = 1;
    if(rc) {
        if(EWOULDBLOCK == errno){
            puts("Another ymp instance is already running");
            exit(31);
        }
    }
}

int run(char* command){
    return system(command);
}

int run_silent(char* command){
    char* buf = malloc((strlen(command)+10)*sizeof(char));
    strcpy(buf,command);
    strcat(buf," >/dev/null");
    return system(buf);
}

FILE* process;

char* getoutput(char* command){
    char* long_buffer = malloc(sizeof(char)*1024*1024);
    process = popen(command,"r");
    size_t len = 0;
    char *line = NULL;
    ssize_t read;
    strcpy(long_buffer,"");
    if(process == NULL){
        return "";
    }
    while ((read = getline(&line, &len, process)) != -1) {
        strcat(long_buffer,line);
    }
    return long_buffer;
}


int run_args(char* args[]){
    pid_t pid = fork();
    if(pid == 0){
        char *envp[] = {"TERM=linux", "PATH=/usr/bin:/bin:/usr/sbin:/sbin", NULL};
        _exit(execvpe(which(args[0]),args,envp));
        return 127;
    }else{
        int status;
        wait(&status);
        return status;
    }
    return 127;
}

long get_epoch(){
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return 1000000 * tv.tv_sec + tv.tv_usec;
}
#endif
