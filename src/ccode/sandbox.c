#ifndef _sandbox
#define _sandbox
#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <signal.h>
char* which(char* cmd);
void sandbox(char** args){
    int flag = CLONE_NEWUSER | CLONE_NEWUTS | CLONE_NEWIPC | CLONE_NEWPID | CLONE_NEWNS | CLONE_NEWNET | SIGCHLD ;
    pid_t pid = fork();
    if(pid == 0) {
        unshare(flag);
        execvp(which(args[0]),args);
    }
}
#endif