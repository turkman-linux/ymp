#include <stdio.h>
#include <string.h>

// functions from vala source
void print(char* msg);
void print_stderr(char* msg);
void error_add(char* msg);
char* colorize(char* msg, char* num);
char* ccolorize(char* msg, char* num);
int get_bool(char* val);

//headers of functions
void warning_fn(char* msg);
void debug_fn(char* msg);
void info_fn(char* msg);
char* colorize_fn(char* msg, int color);
char* colorize_dummy(char* msg, int color);


// function pointer type definitions
typedef void (*fn_logger)(char*);
typedef char* (*fn_colorize)(char*,int);

// logger function pointer
fn_logger print_ptr;
fn_logger print_stderr_ptr;
fn_logger warning_ptr;
fn_logger info_ptr;
fn_logger debug_ptr;
fn_colorize colorize_ptr;

// print functions area
void print_fn(char* message, int new_line, int err){
    if(strcmp(message,"")==0){
        return;
    }
    FILE *fd=stdout;
    if(err){
        fd=stderr;
    }
    fprintf(fd,"%s",message);
    if(new_line){
        fputc('\n',fd);
    }
    fflush(fd);
}

void cprint(char* message){
    fputs(message,stdout);
    fputc('\n',stdout);
    fflush(stdout);
}
void cprint_stderr(char* message){
    fputs(message,stderr);
    fputc('\n',stderr);
    fflush(stderr);
}

void cprint_dummy(char* message){}


// logger functions
void print(char* msg){
    print_ptr(msg);
}

void print_stderr(char* msg){
    print_stderr_ptr(msg);
}

void warning(char* msg){
    warning_ptr(msg);
}

void info(char* msg){
    info_ptr(msg);
}

void debug(char* msg){
    debug_ptr(msg);
}

// init function
void logger_init(){
    if(get_bool("quiet")){
        print_ptr = cprint_dummy;
        print_stderr_ptr = cprint_dummy;
    }else{
        print_ptr = cprint;
        print_stderr_ptr = cprint_stderr;
    }
    if(get_bool("ignore-warning")){
        warning_ptr = cprint_stderr;
    }else if(get_bool("warning-as-error")){
        warning_ptr = error_add;
    }else{
        warning_ptr = warning_fn;
    }
    if(get_bool("verbose")){
        info_ptr = info_fn;
    }else{
        info_ptr = cprint_dummy;
    }
    if(get_bool("debug")){
        debug_ptr = debug_fn;
    }else{
        debug_ptr = cprint_dummy;
    }
    if (get_bool("no-color")){
        colorize_ptr = colorize_dummy;
    }else{
        colorize_ptr = colorize_fn;
    }
}
