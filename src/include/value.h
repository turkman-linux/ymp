#include <stdbool.h>
#include <string.h>
#ifdef __STRICT_ANSI__
#define strdup(A) strcpy(calloc(strlen(A) + 1, sizeof(char)), A);
#endif
char* get_value(char* name);
void set_value(char* name, char* value);
void set_value_readonly(char* name, char* value);
bool get_bool(char* name);
void set_bool(char* name, bool value);
char** get_variable_names(int* len);
