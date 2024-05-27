#ifndef LOGGER_H
#define LOGGER_H

extern char* build_string(char* message, ...);

void print(char* msg);
void warning(char* msg);
#if DEBUG
void debug(char* msg);
void debug_fn(char* message);
#endif
void info(char* msg);
void print_stderr(char* msg);
void warning_fn(char* message);
void info_fn(char* message);
void logger_init();
void set_terminal_title(char* message);

#if DEBUG
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

#define finfo(A, ...) \
    do { \
        char* message = build_string(A, ##__VA_ARGS__); \
        info(message); \
        free(message); \
    } while (0)

#define fwarning(A, ...) \
    do { \
        char* message = build_string(A, ##__VA_ARGS__); \
        warning(message); \
        free(message); \
    } while (0)

#endif /* LOGGER_H */

