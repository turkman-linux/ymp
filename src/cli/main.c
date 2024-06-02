#if no_locale
char* _(char* msg){
    return msg;
}
#else
#include <libintl.h>
#include <locale.h>
#endif
#include <ymp.h>
#include <stdio.h>
#include <unistd.h>

#if musl
extern int fileno(FILE *f);
#endif

int main(int argc, char** argv, char** envp){
#ifndef no_locale
    setlocale(LC_ALL, "");
    bindtextdomain("ymp", NULL);
    textdomain("ymp");
    #define _ gettext
#endif
    /*
    ██████╗  ██╗
    ╚════██╗███║
     █████╔╝╚██║
     ╚═══██╗ ██║
    ██████╔╝ ██║
    ╚═════╝  ╚═╝
    */
    ymp_init(argv, argc);
    if (get_bool("version")){
        write_version();
        exit(0);
    }if(argc < 2){
        gchar* c1 = g_strconcat(_ ("No command given."), "\n", NULL);
        gchar* c2;
        if (isatty(fileno(stdout))){
            c2 = g_strdup_printf ("\x1b[%dm%s\x1b[;0m", 31, _ ("ymp help"));
        } else {
            c2 = g_strdup_printf ("%s", _ ("ymp help"));
        }
        gchar* c3 = g_strdup_printf (_ ("Run %s for more information about usage."), c2);
        gchar* msg =  g_strconcat (c1, c3, NULL);
        error_add (msg);
        free(msg);
        free(c3);
        free(c2);
        free(c1);
        error (31);
    }else {
        ymp_init (argv, argc);
        add_process (argv[1], argv+2, argc-2);
        ymp_run ();
    }
    if(has_error()){
        error(1);
    }
    exit(0);
}
