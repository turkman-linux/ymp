#include <sys/file.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

void single_instance(){
    int pid_file = open("/run/ymp.pid", O_CREAT | O_RDWR, 0666);
    int rc = flock(pid_file, LOCK_EX | LOCK_NB);
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


FILE* process;
char long_buffer[1024*1024*1024];
char medium_buffer[1024*1024];

char* getoutput(char* command){
    process = popen(command,"r");
    size_t len = 0;
    char *line = NULL;
    ssize_t read;
    strcpy(long_buffer,"");
    fprintf(stderr,"%s\n",command);
    if(process == NULL){
        return "";
    }
    while ((read = getline(&line, &len, process)) != -1) {
        strcat(long_buffer,line);
    }
    return long_buffer;
}

