#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>

#ifndef _POSIX_C_SOURCE
#define _POSIX_C_SOURCE
#endif

#ifdef __STRICT_ANSI__
#define strdup(A) strcpy(calloc(strlen(A) + 1, sizeof(char)), A);
int setenv(const char *name, const char *value, int overwrite);
#endif

typedef struct _variable {
    char* name;
    char* value;
    bool read_only;
} variable;

static variable* vars;
static size_t var_count = 0;

static void set_value_fn(char* name, char* value, bool read_only){
    if(name == NULL || value == NULL){
        return;
    }
    size_t i=0;
    for(i=0;i<var_count;i++){
        if(strcmp(vars[i].name, name) == 0 && ! vars[i].read_only){
            vars[i].value = strdup(value);
            return;
        }
    }
    if(vars == NULL){
        vars = calloc(1, sizeof(variable));
    }
    vars = realloc(vars, (var_count+1)* sizeof(variable));
    vars[var_count].name = strdup(name);
    vars[var_count].value = strdup(value);
    vars[var_count].read_only = read_only;
    var_count++;
}

void set_value(char* name, char* value){
    set_value_fn(name, value, false);
}

void set_value_readonly(char* name, char* value){
    set_value_fn(name, value, false);
}

char* get_value(char* name){
    size_t i=0;
    for(i=0;i<var_count;i++){
        if(strcmp(vars[i].name, name) == 0){
            /*printf("%s %s %s\n", vars[i].name, name, vars[i].value);*/
            return strdup(vars[i].value);
        }
    }
    return strdup("");
}

bool get_bool(char* name){
    return strcmp(get_value(name), "true") == 0;
}

void set_bool(char* name, bool value){
    if(value){
        set_value(name,"true");
    } else{
        set_value(name,"false");
    }
}

char** get_variable_names(int* len){
    char** ret = calloc(var_count+1, sizeof(char*));
    size_t i=0;
    for(i=0; i<var_count; i++){
        ret[i] = strdup(vars[i].name);
    }
    *len = var_count;
    return ret;
}


extern char **environ;
static char **environ_save;
void clear_env(){
    char *path = strdup(getenv("PATH"));
    char *env[1];
    env[0] = NULL;
    environ = env;
    setenv("PATH", path, 1);
}

void save_env(){
    int len = 0;
    while(environ[len]){
        len++;
    }
    char **ret = malloc((len+1)*sizeof(char*));
    len = 0;
    while(environ[len]){
        ret[len] = strdup(environ[len]);
        len++;
    }
    ret[len] = NULL;
    environ_save = ret;
}

void restore_env(){
    environ = environ_save;
}

