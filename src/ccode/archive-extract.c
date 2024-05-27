#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <archive.h>
#include <archive_entry.h>

extern void error_add(char* message);

extern char* build_string(char* format, ...);

#ifdef __STRICT_ANSI__
#define strdup(A) strcpy(calloc(strlen(A) + 1, sizeof(char)), A)
#endif


#if DEBUG
extern void debug(char* message);
#define fdebug(A, ...) \
    do { \
        char* message = build_string(A, ##__VA_ARGS__); \
        debug(message); \
        free(message); \
    } while (0)
#else
#define debug(A)
#define fdebug(A,...)
#endif

extern void info(char* message);
#define finfo(A, ...) \
    do { \
        char* message = build_string(A, ##__VA_ARGS__); \
        info(message); \
        free(message); \
    } while (0)

#include <archive_extract.h>

archive* archive_new(){
    fdebug("new archive");
    archive *data = calloc(1, sizeof(archive));
    data->add_list_size = 0;
    data->a = array_new();
    return data;
}

void archive_unref(archive *data){
    free(data);
}

void archive_load(archive *data, char* path) {
    fdebug("archive load: %s", path);
    data->archive_path = strdup(path);
    archive_set_type(data, "zip", "none");
}

void archive_load_archive(archive *data) {
    data->archive = archive_read_new();
    archive_read_support_filter_all(data->archive);
    archive_read_support_format_all(data->archive);
    if (archive_read_open_filename(data->archive, data->archive_path, 10240) != ARCHIVE_OK) {
        char* error_msg = build_string("Failed to open archive: %s", archive_error_string(data->archive));
        error_add(error_msg);
    }
}

void archive_set_target(archive *data, char* target){
    fdebug("archive set target: %s", target);
    data->target_path = strdup(target);
}

int archive_is_archive(archive *data, char *path) {
    fdebug("is archive: %s", path);
    data->archive = archive_read_new();
    archive_read_support_filter_all(data->archive);
    archive_read_support_format_all(data->archive);
    int result = archive_read_open_filename(data->archive, path, 10240);
    return result == ARCHIVE_OK;
}

char** archive_list_files(archive *data, int* len) {
    fdebug("archive list files: %s", data->archive_path);
    archive_load_archive(data);
    struct archive_entry *entry;
    char **ret = NULL;
    size_t ret_size = 0;
    while (archive_read_next_header(data->archive, &entry) == ARCHIVE_OK) {
        array_add(data->a,archive_entry_pathname(entry));
        archive_read_data_skip(data->archive);
    }
    return array_get(data->a, len);
}

void archive_add(archive *data, char *path) {
    fdebug("archive add: %s", path);
    array_add(data->a, path);
}

void archive_create(archive *data){
    fdebug("archive create: %s", data->archive_path);
    int *len;
    archive_write(data, data->archive_path, array_get(data->a, &len));
}

void archive_extract(archive *data, char *path) {
    fdebug("archive extract: %s => %s", data->archive_path, path);
    archive_load_archive(data);
    struct archive_entry *entry;
    while (archive_read_next_header(data->archive, &entry) == ARCHIVE_OK) {
        char *entry_path = archive_entry_pathname(entry);
        char *target_file = NULL;
        if(strlen(entry_path) == 0){
            continue;
        } else if (strcmp(entry_path, path) != 0) {
            continue;
        }
        finfo("Extract: %s", entry_path);
        if (data->target_path != NULL) {
            size_t target_file_len = strlen(data->target_path) + strlen(entry_path) + 2;
            target_file = malloc(target_file_len);
            snprintf((char *)target_file, target_file_len, "%s/%s", data->target_path, entry_path);
        } else {
            target_file = entry_path;
        }
        /* Check if entry is a directory */
        mode_t mode = archive_entry_filetype(entry);
        if (S_ISDIR(mode)) {
            /* Create the directory if it doesn't exist */
            if (access(target_file, F_OK) != -1) {
                continue;
            }
            if (mkdir(target_file, 0755) != 0) {
                char* error_msg = build_string("Failed to create directory: %s", target_file);
                error_add(error_msg);
            }
            continue;
        }
        FILE *file = fopen(target_file, "wb");
        if (file == NULL) {
            char* error_msg = build_string("Failed to open file for writing: %s", target_file);
           error_add(error_msg);
        }
        char buffer[4096];
        ssize_t size;
        while ((size = archive_read_data(data->archive, buffer, sizeof(buffer))) > 0) {
            fwrite(buffer, 1, size, file);
        }
        fclose(file);
        chmod(target_file, 0755);
    }
}
           
            
char* archive_readfile(archive *data, char *file_path) {
    archive_load_archive(data);
    struct archive_entry *entry;
    char *ret = NULL;
    while (archive_read_next_header(data->archive, &entry) == ARCHIVE_OK) {
        char *entry_path = archive_entry_pathname(entry);
        if (strcmp(entry_path, file_path) != 0)
            continue;
        size_t size = archive_entry_size(entry);
        ret = (char *)malloc(size + 1);
        if (ret == NULL) {
            char* error_msg = build_string("Memory allocation failed");
           error_add(error_msg);
        }
        ssize_t bytes_read = archive_read_data(data->archive, ret, size);
        if (bytes_read < 0) {
            char* error_msg = build_string("Failed to read file: %s", archive_error_string(data->archive));
            free(ret);
           error_add(error_msg);
        }
        ret[bytes_read] = '\0';
        break;
    }
    archive_read_close(data->archive);
    return ret;
}

#include <sys/stat.h>

void archive_extract_all(archive *data) {
    archive_load_archive(data);
    struct archive_entry *entry;
    while (archive_read_next_header(data->archive, &entry) == ARCHIVE_OK) {
        char *entry_path = archive_entry_pathname(entry);
        char *target_file = NULL;
        if(strlen(entry_path) == 0){
            continue;
        }
        finfo("Extract: %s", entry_path);
        if (data->target_path != NULL) {
            size_t target_file_len = strlen(data->target_path) + strlen(entry_path) + 2;
            target_file = malloc(target_file_len);
            snprintf((char *)target_file, target_file_len, "%s/%s", data->target_path, entry_path);
        } else {
            target_file = entry_path;
        }
        /* Check if entry is a directory */
        mode_t mode = archive_entry_filetype(entry);
        if (S_ISDIR(mode)) {
            /* Create the directory if it doesn't exist */
            if (access(target_file, F_OK) != -1) {
                continue;
            }
            if (mkdir(target_file, 0755) != 0) {
                char* error_msg = build_string("Failed to create directory: %s", target_file);
               error_add(error_msg);
            }
            continue;
        }
        FILE *file = fopen(target_file, "wb");
        if (file == NULL) {
            char* error_msg = build_string("Failed to open file for writing: %s", target_file);
           error_add(error_msg);
        }
        char buffer[4096];
        ssize_t size;
        while ((size = archive_read_data(data->archive, buffer, sizeof(buffer))) > 0){
            fwrite(buffer, 1, size, file);
        }
        fclose(file);
        chmod(target_file, 0755);
    }
}


