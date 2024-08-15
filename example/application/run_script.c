/* Ymp header */
#include <ymp.h>
/*
Build command:
     gcc `pkg-config --cflags --libs ymp` run_script.c -o run_script
*/

/* Main function */
int main(int argc, char** argv){
    /* Start ymp */
    ymp_init(argv, argc);
    /* add a script */
    add_script("echo hello world");
    /* run */
    return ymp_run();
}
