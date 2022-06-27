#define _GNU_SOURCE
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define FILE_OK 0
#define FILE_NOT_EXIST 1
#define FILE_TO_LARGE 2
#define FILE_READ_ERROR 3

//header
int status = 0;
char ** strsplit(const char * s,
    const char * delim);
int strcount(char * buf, char * c);
char * readlines(const char * filename);
int iseq(char * str1, char * str2);

char * ini_get_area(char * ctx, char * name) {
    int len = strcount(ctx, "\n");
    char ** lines = strsplit(ctx, "\n");
    char * section = malloc(sizeof(char) * (strlen(name) + 3));
    char * ret = malloc(sizeof(char) * (strlen(ctx) + 1));
    strcpy(ret, "");
    strcpy(section, "[");
    strcat(section, name);
    strcat(section, "]");
    status = 0;
    for (int i = 0; i < len; i++) {
        if (0 == strcmp(lines[i], section)) {
            status = 1;
        } else if (strlen(lines[i]) == 0 || lines[i][0] == '[') {
            status = 0;
        }
        if (status == 1 && strlen(lines[i]) != 0 && lines[i][0] != '#' && lines[i][0] != '\n') {
            strcat(ret, lines[i]);
            strcat(ret, "\n");
        }
    }
    return (char * ) ret;
}
char * val_process(char * ctx, char * name) {
    char * ret = malloc(sizeof(char) * (strlen(ctx)));
    for (int i = strlen(name); i < strlen(ctx) + 1; i++) {
        ret[i - strlen(name)] = ctx[i];
    }
    ret[strlen(ctx) - strlen(name) + 1] = '\0';
    return ret;
}
char * ini_get_value(char * ctx, char * name) {
    int len = strcount(ctx, "\n");
    char ** lines = strsplit(ctx, "\n");
    char * section = malloc(sizeof(char) * (strlen(name) + 2));
    char * ret = malloc(sizeof(char) * (strlen(ctx) + 2));
    strcpy(ret, "");
    strcpy(section, name);
    strcat(section, "=");
    for (int i = 0; i < len; i++) {
        if (1 == iseq(section, lines[i])) {
            ret = val_process((char * ) lines[i], section);
        }
    }
    return ret;
}

int iseq(char * str1, char * str2) {
    for (int i = 0; i < strlen(str1); i++) {
        if (str1[i] != str2[i]) {
            return 0;
        }
    }
    return 1;
}

//util functions
int strcount(char * buf, char * c) {
    int size = 1;
    for (int i = 0; i <= strlen(buf); i++) {
        if (buf[i] == c[0]) {
            size++;
        }
    }
    return size;
}
char ** strsplit(const char * s,
    const char * delim) {
    void * data;
    char * _s = (char * ) s;
    const char ** ptrs;
    size_t
    ptrsSize,
    nbWords = 1,
        sLen = strlen(s),
        delimLen = strlen(delim);

    while ((_s = strstr(_s, delim))) {
        _s += delimLen;
        ++nbWords;
    }
    ptrsSize = (nbWords + 1) * sizeof(char * );
    ptrs =
        data = malloc(ptrsSize + sLen + 1);
    if (data) {
        * ptrs =
            _s = strcpy(((char * ) data) + ptrsSize, s);
        if (nbWords > 1) {
            while ((_s = strstr(_s, delim))) {
                * _s = '\0';
                _s += delimLen;
                *++ptrs = _s;
            }
        }
        *++ptrs = NULL;
    }
    return data;
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

            return NULL;
        }

        buffer = (char * ) malloc(length + 1);

        if (length) {
            read_length = fread(buffer, 1, length, f);

            if (length != read_length) {
                * err = FILE_READ_ERROR;

                return NULL;
            }
        }

        fclose(f);

        * err = FILE_OK;
        buffer[length] = '\0';
        * f_size = length;
    } else {
        * err = FILE_NOT_EXIST;

        return NULL;
    }

    return buffer;
}
char * readlines(const char * filename) {
    int err;
    size_t f_size;
    char * f_data;

    f_data = c_read_file(filename, & err, & f_size);

    if (err) {
        if (err == FILE_NOT_EXIST) {
            fprintf(stderr, "Error: %s\n", "file not found.", err);
        } else if (err == FILE_READ_ERROR) {
            fprintf(stderr, "Error: %s\n", "failed to read file.", err);
        }
        exit(err);
    } else {
        return f_data;
    }
}
