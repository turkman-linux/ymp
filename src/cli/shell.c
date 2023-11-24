#include <ymp.h>

static gint _main (gint len, gchar** args){
    ymp_init (args, len);
    add_process ("shell", args + 1, len - 1);
    ymp_run ();
    error (1);
    return 0;
}

int main(int argc, char** argv){
    return _main(argc, argv);
}
