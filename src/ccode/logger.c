#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>

/* functions from vala source */
int get_bool(char* val);
void colorize_init();

/* string add function*/
char* str_add(char* s1, char* s2);

/* string builder */
char* build_string(char* format, ...);


extern char* colorize(char* message, int color);
extern char* gettext(char* message);

#define yellow 33
#define green 32
#define _(A) gettext(A)

#include <error.h>
#include <logger.h>

/* define function headers */
void cprint(char* msg);
void cprint_stderr(char* msg);
void cprint_dummy(char* msg);


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
    if(new_line){
        message = str_add(message, "\n");
    }
    write(err+1, message, strlen(message));
}

void warning_fn (char* message) {
    print_stderr (build_string("%s: %s",colorize (_ ("WARNING"), yellow), message));
}

void info_fn (char* message) {
    print_stderr (build_string("%s: %s",colorize (_ ("INFO"), yellow), message));
}

void cprint(char* message){
    message = str_add(message, "\n");
    write(1, message, strlen(message));
}


void set_terminal_title (char* msg) {
    #if NOCOLOR
       return;
    #else
    if (!get_bool ("no-color")) {
        print_fn (build_string("%s%s%s","\x1b]2;", msg, "\x07"), false, false);
    }
    #endif
}


#ifdef DEBUG
static long last_debug_time = -1;
void debug_fn(char *message) {
    if (last_debug_time == -1) {
        last_debug_time = time(NULL);
    }

    time_t current_time = time(NULL);
    int elapsed_time = (int)(current_time - last_debug_time);

    print_stderr (build_string( "[%s:%d]: %s\n", "DEBUG", elapsed_time, message));

    last_debug_time = current_time;
}
#endif
void cprint_stderr(char* message){
    message = str_add(message, "\n");
    write(2, message, strlen(message));
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
