#ifndef _file
#define _file
#define _GNU_SOURCE
#include <stdio.h>
#include <stdbool.h>
#include <stdarg.h>
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

#ifndef info
void info(char* msg);
#endif

#ifndef debug
void debug(char* msg);
#endif
char* str_add(char* s1, char* s2);

long filesize(char* path){
    stat(path, &st);
    return st.st_size;
}

void fs_sync(){
    # ifdef EXPERIMENTAL
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
    #else
        sync();
    #endif
}

int issymlink(const char *filename){
    if(lstat(filename, &st) < 0) {
        return FALSE;
    }
    return S_ISLNK(st.st_mode);
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

static char * c_read_file(const char * f_name, int * err, size_t * f_size) {
    char * buffer;
    size_t length;
    FILE * f = fopen(f_name, "rb");
    size_t read_length;

    if (f) {
        fseek(f, 0, SEEK_END);
        length = ftell(f);
        fseek(f, 0, SEEK_SET);

        /* 1 GiB; best not to load a whole large file in one string */
        if (length > 1073741824) {
            * err = FILE_TO_LARGE;

            return "";
        }

        buffer = (char * ) calloc(length + 1, sizeof(char));

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
            fprintf(stderr, "Error: %s (%d) %s\n", "file not found.", err, filename);
        } else if (err == FILE_READ_ERROR) {
            fprintf(stderr, "Error: %s (%d) %s\n", "failed to read file.", err,filename);
        }
        return "";
    } else {
        return f_data;
    }
}

char* c_realpath(char* path){
    return realpath(path,NULL);
}

void cd(char *path) {
    #ifdef debug
    /* Print a debug message indicating the change of directory */
    debug("Change directory:");
    debug(path);
    #endif

    /* Check if the specified path is not a directory */
    struct stat st;
    if (stat(path, &st) != 0 || !S_ISDIR(st.st_mode)) {
        /* If it's not a directory, try to create the directory */
        if (mkdir(path, 0777) != 0) {
            perror("Error creating directory");
            return;
        }
    }

    /* Set the current directory to the specified path */
    if (chdir(path) != 0) {
        perror("Error changing directory");
        return;
    }
}

void write_to_file(const char *which, const char *format, ...) {
  FILE * fu = fopen(which, "w");
  va_list args;
  va_start(args, format);
  if (vfprintf(fu, format, args) < 0) {
    printf("cannot write");
  }
  fclose(fu);
}

void writefile(char* path, char* ctx){
    write_to_file(path,"%s", ctx);
}

mode_t c_umask(mode_t mask){
    return umask(mask);
}

int isfile(char* path){
    #ifdef debug
    debug(str_add("Check file: ", path));
    #endif
    int fs = stat (path, &st);
    int ls = lstat (path, &st);
    return (!ls || !fs) && ! isdir (path);
}

#ifndef no_libmagic
#include <magic.h>
char* get_magic_mime_type(char* path){
  const char *mime;
  magic_t magic;

  magic = magic_open(MAGIC_MIME_TYPE);
  magic_load(magic, NULL);
  mime = magic_file(magic, path);

  magic_close(magic);
  return strdup(mime);
}
#endif
#endif
