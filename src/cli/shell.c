#include <ymp.h>

static gint _main (gint len, gchar** args){
    Ymp *ymp = ymp_init (args, len);
    ymp_add_process (ymp, "shell", args + 1, len - 1);
    ymp_run (ymp);
    error (1);
    return 0;
}

int main(int argc, char** argv){
    return _main(argc, argv);
}
