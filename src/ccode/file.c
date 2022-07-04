#ifndef _file
#define _file
#define _GNU_SOURCE
#include <stdio.h>
#include <stdbool.h>
#include <sys/stat.h>
#include <sys/utsname.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>

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

void fs_sync(){
    /*if(getuid() == 0){
        FILE *f = fopen("/proc/sysrq-trigger","w");
        fputs("s",f);
        fclose(f);
    }else{*/
        sync();
    //}
}

void create_dir(const char *dir) {
    char tmp[PATH_MAX];
    char *p = NULL;
    size_t len;

    snprintf(tmp, sizeof(tmp),"%s",dir);
    len = strlen(tmp);
    if (tmp[len - 1] == '/')
        tmp[len - 1] = 0;
    for (p = tmp + 1; *p; p++)
        if (*p == '/') {
            *p = 0;
            mkdir(tmp, S_IRWXU);
            *p = '/';
        }
    mkdir(tmp, S_IRWXU);
}

#endif
