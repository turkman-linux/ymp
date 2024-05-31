#include <ymp.h>

int main(int argc, char** argv){
    ymp_init (argv, argc);
    add_process ("shell", argv + 1, argc - 1);
    ymp_run ();
    error (1);
    exit(0);
}

