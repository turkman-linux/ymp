#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>

/* functions from vala source */
void print(char* msg);
void print_stderr(char* msg);
void error_add(char* msg);
int get_bool(char* val);
void colorize_init();

/* headers of functions */
void cprint(char* msg);
void cprint_stderr(char* msg);
void cprint_dummy(char* msg);
void warning_fn(char* msg);
#ifdef DEBUG
void debug_fn(char* msg);
#endif
void info_fn(char* msg);


/* function pointer type definitions */
typedef void (*fn_logger)(char*);

/* logger function pointer */
fn_logger print_ptr = cprint;
fn_logger print_stderr_ptr = cprint_stderr;
fn_logger warning_ptr = warning_fn;
fn_logger info_ptr = cprint_dummy;
#ifdef DEBUG
fn_logger debug_ptr = cprint_dummy;
#endif

/* print functions area */
void print_fn(char* message, int new_line, int err){
    if(strcmp(message,"")==0){
        return;
    }
    int fd=1;
    if(err){
        fd=2;
    }
    write(fd, message, strlen(message));
    if(new_line){
        write(fd, "\n", 1);
    }
}

void cprint(char* message){
    write(1, message, strlen(message));
    write(1, "\n", 1);
}
void cprint_stderr(char* message){
    write(2, message, strlen(message));
    write(2, "\n", 1);
}

void cprint_dummy(char* message){
    (void)message;
}


/* logger functions */
void print(char* msg){
    if(print_ptr){
        print_ptr(msg);
    }
}

void print_stderr(char* msg){
    if(print_stderr_ptr){
        print_stderr_ptr(msg);
    }
}

void warning(char* msg){
    if(warning_ptr){
        warning_ptr(msg);
    }
}

void info(char* msg){
    if(info_ptr){
        info_ptr(msg);
    }
}
#ifdef DEBUG
void debug(char* msg){
    if(debug_ptr){
        debug_ptr(msg);
    }
}
#endif

/* init function */
void logger_init(){
    if(get_bool("quiet")){
        print_ptr = cprint_dummy;
        print_stderr_ptr = cprint_dummy;
    }
    if(get_bool("ignore-warning")){
        warning_ptr = cprint_stderr;
    }else if(get_bool("warning-as-error")){
        warning_ptr = error_add;
    }
    if(get_bool("verbose")){
        info_ptr = info_fn;
    }
    #ifdef DEBUG
    if(get_bool("debug")){
        debug_ptr = debug_fn;
    }
    #endif
    #ifndef NOCOLOR
    colorize_init();
    #endif
}
