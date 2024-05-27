#ifndef LOGGER_H
#define LOGGER_H

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

#endif /* LOGGER_H */

