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
#include <sys/prctl.h> 
#include <unistd.h>

#ifndef which
char* which(char* path);
#endif

#ifndef str_add
char* str_add(char* str1, char* str2);
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
int run_args(char* args[]){
    pid_t pid = fork();
    if(pid == 0){
        int r = prctl(PR_SET_PDEATHSIG, SIGHUP);
        if (r == -1){
            exit(1);
        }
        char *envp[] = {
            "TERM=linux",
            "PATH=/usr/bin:/bin:/usr/sbin:/sbin",
            str_add("OPERATION=",getenv("OPERATION")),
            NULL
        };
        exit(execvpe(which(args[0]),args,envp));
        exit(127);
    }else{
        int status;
        kill(wait(&status),9);
        return status;
    }
    return 127;
}

int run_args_silent(char* args[]){
    pid_t pid = fork();
    if(pid == 0){
        int r = prctl(PR_SET_PDEATHSIG, SIGHUP);
        if (r == -1){
            exit(1);
        }
        char *envp[] = {
            "TERM=linux",
            "PATH=/usr/bin:/bin:/usr/sbin:/sbin",
            str_add("OPERATION=",getenv("OPERATION")),
            NULL
        };
        int devnull = open("/dev/null", O_WRONLY);
        dup2(devnull, STDOUT_FILENO);
        dup2(devnull, STDERR_FILENO);
        exit(execvpe(which(args[0]),args,envp));
        exit(127);
    }else{
        int status;
        kill(wait(&status),9);
        return status;
    }
    return 127;
}

int run(char* command){
    char* cmd[] = {"sh","-c",command};
    return run_args(cmd);
}

int run_silent(char* command){
    char* cmd[] = {"sh","-c",command};
    return run_args_silent(cmd);
}

long get_epoch(){
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return 1000000 * tv.tv_sec + tv.tv_usec;
}
#endif
