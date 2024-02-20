#ifdef no_fetcher_backend
#include <glib.h>

int fetch (char* url, char* path) {
    gchar** cmd = {"wget", url, "-o", path, NULL};
    return run_args(cmd);
}

char* fetch_string(char* url) {
    gchar* cmd = g_strdup_printf("wget -o - '%s'", url);
    return (char*)getoutput(cmd);
}

#endif
