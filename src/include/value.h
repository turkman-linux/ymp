#include <stdbool.h>
#include <string.h>
char* get_value(char* name);
void set_value(char* name, char* value);
void set_value_readonly(char* name, char* value);
bool get_bool(char* name);
void set_bool(char* name, bool value);
char** get_variable_names(int* len);
