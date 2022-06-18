#ifndef _file
#define _file
#include <stdio.h>
#include <sys/stat.h>
#include <sys/utsname.h>
#include <string.h>
#include <stdlib.h>

struct stat st;

int filesize(char* path){
    stat(path, &st);
    return st.st_size;
}

char* getArch() {
    struct utsname uts;
	int err = uname(&uts);
	if (err != 0) {
		printf("Failed to detect CPU architecture");
		return "UNKNOWN";
	}
	// Allocate memory and copy value into
	char* ret = malloc(sizeof(uts.machine));
	strcpy(ret,uts.machine);
	return ret;
}
#endif
