#ifndef NOCOLOR
#include <string.h>
#include <stdlib.h>
#include <math.h>

#ifndef get_bool
int get_bool(char* name);
#endif

char* int_to_string(int num);

char* ccolorize(char* msg, char* num){
    char* ret = malloc((strlen(msg)+strlen(num))*(sizeof(char)+13));
    strcpy(ret,"\x1b[");
    strcat(ret,num);
    strcat(ret,"m");
    strcat(ret,msg);
    strcat(ret,"\x1b[0m");
    return ret;
}


char* colorize_fn(char* msg, int color){
    return ccolorize(msg, int_to_string(color));
}
char* colorize_dummy(char* msg, int color){
    char* ret = strdup(msg);
    return ret;
}

typedef char* (*fn_colorize)(char*,int);
fn_colorize colorize_ptr = colorize_fn;

void colorize_init(){
    if (get_bool("no-color")){
        colorize_ptr = colorize_dummy;
    }
}

char* colorize(char* msg, int color){
    return colorize_ptr(msg, color);
}
#else
#include <string.h>
char* colorize(char* msg, int color){
    char* ret = strdup(msg);
    return ret;
}
#endif
