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

#ifndef run_args
int run_args(char** args);
#endif

#ifndef run_args_silent
int run_args_silent(char** args);
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
    char* cmd[] = {"sh","-c",command};
    return run_args(cmd);
}

int run_silent(char* command){
    char* cmd[] = {"sh","-c",command};
    return run_args_silent(cmd);
}

char* getoutput(char* command) {
    FILE *fp = popen(command, "r");
    if (!fp){
        return "";
    }
    char buff[1024*1024];
    char* ret = calloc(1,sizeof(char));
    ret[0] = '\0';
    while (fgets(buff, sizeof(buff), fp) != NULL)
    {
        ret = realloc(ret,sizeof(ret)+sizeof(buff));
        strcat(ret,buff);
    }
    pclose(fp);
    ret = realloc(ret, (strlen(ret)+1) * sizeof(char));
    ret[strlen(ret)] = '\0';
    return ret;
}

long get_epoch(){
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return 1000000 * tv.tv_sec + tv.tv_usec;
}

void freeze(){
    puts("FREEZE");
    while(1);
}

#endif
