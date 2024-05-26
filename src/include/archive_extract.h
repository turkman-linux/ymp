#ifndef ARCHIVE_CREATE_H
#define ARCHIVE_CREATE_H

#include <array.h>

typedef struct archive {
    struct archive *archive;
    char *archive_path;
    char *target_path;
    int add_list_size;
    array *a;
} archive;

archive* archive_new();
void archive_create();
void archive_unref(archive* arch);
void archive_load(archive* arch, char* path);
void archive_set_target(archive* arch, char* path);
void archive_extract_all(archive* arch);
void archive_extract(archive* arch, char* path);
void archive_create_archive(archive* arch);
void archive_add(archive* arch, char* path);
char* archive_readfile(archive* arch, char* path);
char** archive_list_files(archive* arch, int* len);
int archive_is_archive(archive* arch, char* path);

#endif /* ARCHIVE_CREATE_H */

