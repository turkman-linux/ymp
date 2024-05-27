#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <array.h>

#include <error.h>

#ifdef __STRICT_ANSI__
#define strdup(A) strcpy(calloc(strlen(A) + 1, sizeof(char)), A)
#endif


extern bool get_bool(char* value);
extern char* build_string(char* format, ...);
extern void print_stderr(char* message);
extern char* colorize(char* message, int color);
extern char* gettext(char* message);
#define _(A) gettext(A)
#define red 31

static array *error_arr;

void error(int status){
    if(!error_arr){
        error_arr = array_new();
        return;
    }
    size_t i;
    size_t len = 0;
    char** errs = array_get(error_arr, &len);
    if(len > 0 && !get_bool ("ignore-error")) {
        for(i=0;i<len;i++){
            if(errs[i] != NULL){
                print_stderr(build_string("%s: %s", colorize(_ ("ERROR"), red), strdup(errs[i])));
            }
        }
        if(!get_bool ("shellmode")){
            exit(status);
        }
    }
    array_unref(error_arr);
    error_arr = array_new();
}

void error_add(char* message) {
    if(!error_arr){
        error_arr = array_new();
    }
    array_add(error_arr, message);
}

bool has_error(){
    if(!error_arr){
        error_arr = array_new();
    }
    return array_length(error_arr) > 0;
}
