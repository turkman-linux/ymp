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
#include <dlfcn.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include <ctype.h>

#include <glib.h>


#define FILE_OK 0
#define FILE_NOT_EXIST 1
#define FILE_TO_LARGE 2
#define FILE_READ_ERROR 3

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

#ifndef info
void info(char* msg);
#endif

#ifndef debug
void debug(char* msg);
#endif
char* str_add(char* s1, char* s2);

#include <logger.h>
#include <error.h>

uint64_t filesize(char* path){
    struct stat st;
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

gboolean issymlink(const char *filename){
    if(filename == NULL){
        return FALSE;
    }
    struct stat st;
    if(lstat(filename, &st) < 0) {
        return FALSE;
    }
    return S_ISLNK(st.st_mode);
}

gboolean isdir(char *path){
    if(path == NULL){
        return FALSE;
    }
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

#define c_mkdir(A, B) \
    if (strlen(A) > 0 && mkdir(A, B) < 0 && !isexists(A)) { \
        ferror_add("%s: %s", "failed to create directory", A); \
}

#ifndef isexists
extern gboolean isexists(char* path);
#endif

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
            c_mkdir(tmp, 0755);
            *p = '/';
        }
    c_mkdir(tmp, 0755);
}


static char * c_read_file(const char * f_name, int * err, size_t * f_size) {
    char *buffer = NULL;
    FILE *f = fopen(f_name, "rb");
    if (!f) {
        *err = FILE_NOT_EXIST;
        return NULL; /* Return NULL on error */
    }

    fseek(f, 0, SEEK_END);
    size_t length = ftell(f);
    fseek(f, 0, SEEK_SET);

    if (length > 1073741824) {
        fclose(f);
        *err = FILE_TO_LARGE;
        return ""; /* Return empty on error */
    }

    buffer = (char *)calloc(length + 1, sizeof(char));
    if (!buffer) {
        fclose(f);
        *err = FILE_READ_ERROR;
        return ""; /* Return empty on error */
    }

    size_t read_length = fread(buffer, 1, length, f);
    fclose(f);

    if (length != read_length) {
        free(buffer); /* Free on error */
        *err = FILE_READ_ERROR;
        return ""; /* Return empty on error */
    }

    *err = FILE_OK;
    buffer[length] = '\0';
    *f_size = length;
    return buffer; /* Return the allocated buffer */
}


char * readfile_raw(const char * filename) {
    int err;
    size_t f_size;
    char * f_data;

    f_data = c_read_file(filename, & err, & f_size);

    if (err) {
        if (err == FILE_NOT_EXIST) {
            ferror_add("%s (%d) %s\n", "file not found.", err, filename);
        } else if (err == FILE_READ_ERROR) {
            ferror_add("%s (%d) %s\n", "failed to read file.", err,filename);
        }
        return ""; /* Return empty on error */
    } else {
        return f_data;
    }
}
char* c_realpath(char* path){
    return realpath(path,NULL);
}

void cd(char *path) {
    #ifdef debug
    debug(str_add("Change directory: ", path));
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
        ferror_add("Error changing directory: %s", path);
        return;
    }
}

char* safedir(char* dir) {
    if(!dir){
        return strdup("");
    }

    #ifdef debug
    debug(str_add("safedir: ", path));
    #endif

    /* Allocate memory for the result */
    size_t len = 0;
    while(dir[len] && dir[len] != '\0'){
        len++;
    }

    /* +2 for '/' and null terminator */
    char* ret = (char*)malloc(len + 2);

    /* Copy the input directory to the result */
    memcpy(ret, dir, len);

    size_t i=0;
    for(i=0;i<len;i++){
        if(!isprint(ret[i])){
            ret[i] = '.';
        }
    }

    /* Replace ".." with "./" */
    while (strstr(ret, "..") != NULL) {
        char* pos = strstr(ret, "..");
        memmove(pos + 1, pos + 2, strlen(pos + 2) + 1);
        *pos = '.';
    }

    /* Replace "//" with "/" */
    while (strstr(ret, "//") != NULL) {
        char* pos = strstr(ret, "//");
        memmove(pos + 1, pos + 2, strlen(pos + 2) + 1);
    }

    /* Replace "/./" with "/" */
    while (strstr(ret, "/./") != NULL) {
        char* pos = strstr(ret, "/./");
        memmove(pos + 1, pos + 3, strlen(pos + 3) + 1);
    }

    /* Remove leading '/' */
    while (len > 0 && ret[0] == '/') {
        memmove(ret, ret + 1, len);
        len--;
    }

    /* Add leading '/' */
    /* +2 for '/' and null terminator */
    char* newRet = (char*)malloc(len + 2);
    strcpy(newRet + 1, ret);
    newRet[0] = '/';
    newRet[len + 1] = '\0';

    /* Free the memory allocated for the intermediate result */
    free(ret);
    return newRet;
}

void write_to_file(const char *which, const char *format, ...) {
  FILE * fu = fopen(which, "w");
  if (fu == NULL) {
      ferror_add("Cannot open for write %s\n", which);
      return;
  }
  va_list args;
  va_start(args, format);
  if (vfprintf(fu, format, args) < 0) {
    ferror_add("Cannot write %s\n", which);
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
    if(path == NULL){
        return FALSE;
    }
    #ifdef debug
    debug(str_add("Check file: ", path));
    #endif
    struct stat st;
    int fs = stat (path, &st);
    int ls = lstat (path, &st);
    return (!ls || !fs) && ! isdir (path);
}

#include <gio/gio.h>
char* get_content_type(char* path){
    gboolean is_certain = FALSE;
    char *content_type = g_content_type_guess (path, NULL, 0, &is_certain);
    if (content_type != NULL) {
        return content_type;
    }
    return "text/plain";
}

typedef ssize_t (*write_func_t)(int, const void *, size_t);

static write_func_t original_write;
ssize_t write(int fd, const void *buf, size_t count) {
    if (!original_write) {
        original_write = dlsym(RTLD_NEXT, "write");
    }

    /* Splitting the buffer into 5MB chunks */
    #define max_chunk_size (100 * 1024 * 1024) /* 5MB */
    size_t bytes_written = 0;
    ssize_t result;

    while (count > 0) {
        size_t chunk_size = (count > max_chunk_size) ? max_chunk_size : count;
        result = original_write(fd, buf + bytes_written, chunk_size);
        if (result < 0) {
            /* Error occurred, return immediately */
            return result;
        }
        bytes_written += result;
        count -= result;
        if(chunk_size == max_chunk_size) {
            fsync(fd);
        }
    }
    return bytes_written;
}
#endif
