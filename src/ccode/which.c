// musl libc fix
#ifndef F_OK
#define F_OK 0
#endif

#ifndef _which
#define _which
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

char* which(char* cmd){
    char* fullPath = getenv("PATH");

    struct stat buffer;
    int exists;
    char* fileOrDirectory = cmd;
    char *fullfilename = calloc(1024, sizeof(char));

    char *token = strtok(fullPath, ":");

    /* walk through other tokens */
    while( token != NULL ){
        sprintf(fullfilename, "%s/%s", token, fileOrDirectory);
        exists = stat( fullfilename, &buffer );
        if ( exists == 0 && ( S_IFREG & buffer.st_mode ) ) {
            char ret[strlen(fullfilename)];
            strcpy(ret,fullfilename);
            return (char*)fullfilename;
        }

        token = strtok(NULL, ":"); /* next token */
    }
    return (char*)cmd;
}

#endif
