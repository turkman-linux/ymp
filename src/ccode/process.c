#ifndef _process
#define _process
#define _GNU_SOURCE
#include <sys/file.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
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


#include <error.h>

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
            error_add("Another ymp instance is already running");
            exit(31);
        }
    }
}

pid_t child_pid, wait_pid;
int status;
int run_args(char **command) {

    child_pid = fork();

    if (child_pid == -1) {
        perror("fork");
        exit(EXIT_FAILURE);
    }

    if (child_pid == 0) {
        /* This code is executed by the child process */
        execvp(command[0], command);

        /* If execvp fails */
        perror("execvp");
        exit(EXIT_FAILURE);
    } else {
        /* This code is executed by the parent process */
        wait_pid = waitpid(child_pid, &status, 0);

        if (wait_pid == -1) {
            perror("waitpid");
            return EXIT_FAILURE;
        }

        if (WIFEXITED(status)) {
            /* Child process terminated normally */
            return WEXITSTATUS(status);
        } else {
            /* Child process did not terminate normally */
            error_add("Child process did not terminate normally.\n");
            return EXIT_FAILURE;
        }
    }
}

int run_args_silent(char **command) {

    child_pid = fork();

    if (child_pid == -1) {
        perror("fork");
        exit(EXIT_FAILURE);
    }

    if (child_pid == 0) {

        /* Redirect standard output and standard error to /dev/null */
        int devnull = open("/dev/null", O_WRONLY);
        dup2(devnull, STDOUT_FILENO);
        dup2(devnull, STDERR_FILENO);
        close(devnull);

        /* This code is executed by the child process */
        execvp(command[0], command);

        /* If execvp fails */
        perror("execvp");
        exit(EXIT_FAILURE);
    } else {
        /* This code is executed by the parent process */
        wait_pid = waitpid(child_pid, &status, 0);

        if (wait_pid == -1) {
            perror("waitpid");
            return EXIT_FAILURE;
        }

        if (WIFEXITED(status)) {
            /* Child process terminated normally */
            return WEXITSTATUS(status);
        } else {
            /* Child process did not terminate normally */
            error_add( "Child process did not terminate normally.\n");
            return EXIT_FAILURE;
        }
    }
}

int run(char* command){
    char* cmd[] = {"sh","-c",command, NULL};
    return run_args(cmd);
}

int run_printf(char* format, ...){
    char cmd[1024];
    va_list args;
    va_start (args, format);
    vsnprintf (cmd, 1023, format, args);
    va_end (args);
    return run(cmd);

}


int run_silent(char* command){
    char* cmd[] = {"sh","-c",command, NULL};
    return run_args_silent(cmd);
}

char* getoutput(const char* command) {
    FILE *fp = popen(command, "r");
    if (!fp) {
        /* Return NULL on failure */
        return NULL;
    }

    /* Allocate initial buffer size */
    size_t bufsize = 1024;
    char* ret = calloc(bufsize, sizeof(char));
    if (!ret) {
        perror("Memory allocation error");
        exit(EXIT_FAILURE);
    }

    /* Initialize the string */
    ret[0] = '\0';

    char buff[1024];
    while (fgets(buff, sizeof(buff), fp) != NULL) {
        /* Resize buffer if needed */
        size_t len = strlen(ret) + strlen(buff) + 1;
        if (len > bufsize) {
            /* Double the buffer size */
            bufsize = len * 2;
            ret = realloc(ret, bufsize * sizeof(char));
            if (!ret) {
                perror("Memory reallocation error");
                exit(EXIT_FAILURE);
            }
        }
        strcat(ret, buff);
    }

    pclose(fp);

    /* Trim the buffer to the actual size needed */
    ret = realloc(ret, (strlen(ret) + 1) * sizeof(char));

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
