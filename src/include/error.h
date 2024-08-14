#include <glib.h>
#include <stdlib.h>

extern char* build_string(char* message, ...);

void error(int status);
void error_add(char* message);
gboolean has_error();

#define ferror_add(A, ...) \
    do { \
        char* message = build_string(A, ##__VA_ARGS__); \
        error_add(message); \
        free(message); \
    } while (0)

