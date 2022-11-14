#ifndef _file
#define _file
#define _GNU_SOURCE
#include <stdio.h>
#include <stdbool.h>
#include <sys/stat.h>
#include <sys/utsname.h>
#include <sys/mman.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <fcntl.h>
#include <dirent.h>

#define FILE_OK 0
#define FILE_NOT_EXIST 1
#define FILE_TO_LARGE 2
#define FILE_READ_ERROR 3

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

struct stat st;

long filesize(char* path){
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
    if(getuid() == 0){
        FILE *f = fopen("/proc/sysrq-trigger","w");
        if(f == NULL){
            sync();
            return;
        }
        fputs("s",f);
        fclose(f);
    }else{
        sync();
    }
}

int issymlink(const char *filename){
    struct stat p_statbuf;
    if(lstat(filename, &p_statbuf) < 0) {
        return FALSE;
    }
    return S_ISLNK(p_statbuf.st_mode);
}

int isdir(char *path){
    if(issymlink(path)){
        return FALSE;
    }
    DIR* dir = opendir(path);
    if(dir){
        closedir(dir);
        return TRUE;
    }else{
        return FALSE;
    }
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
            if(!isdir(tmp))
                mkdir(tmp, 0755);
            *p = '/';
        }
    if(!isdir(tmp))
        mkdir(tmp, 0755);
}

char * c_read_file(const char * f_name, int * err, size_t * f_size) {
    char * buffer;
    size_t length;
    FILE * f = fopen(f_name, "rb");
    size_t read_length;

    if (f) {
        fseek(f, 0, SEEK_END);
        length = ftell(f);
        fseek(f, 0, SEEK_SET);

        // 1 GiB; best not to load a whole large file in one string
        if (length > 1073741824) {
            * err = FILE_TO_LARGE;

            return "";
        }

        buffer = (char * ) malloc(length + 1);

        if (length) {
            read_length = fread(buffer, 1, length, f);

            if (length != read_length) {
                * err = FILE_READ_ERROR;

                return "";
            }
        }

        fclose(f);

        * err = FILE_OK;
        buffer[length] = '\0';
        * f_size = length;
    } else {
        * err = FILE_NOT_EXIST;

        return "";
    }

    return buffer;
}
char * readfile_raw(const char * filename) {
    int err;
    size_t f_size;
    char * f_data;

    f_data = c_read_file(filename, & err, & f_size);

    if (err) {
        if (err == FILE_NOT_EXIST) {
            fprintf(stderr, "Error: %s (%d)\n", "file not found.", err);
        } else if (err == FILE_READ_ERROR) {
            fprintf(stderr, "Error: %s (%d)\n", "failed to read file.", err);
        }
        return "";
    } else {
        return f_data;
    }
}


#endif
