#include <stddef.h>
#include <signal.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <signal.h>
#include <execinfo.h>
#include <unistd.h>
#include <string.h>

typedef void (*sighandler_t)(int);
sighandler_t sigint_signal;

void block_sigint(){
    sigint_signal = signal(SIGINT, SIG_IGN);
}

void unblock_sigint(){
   signal(SIGINT, sigint_signal);
}

static void sigsegv_handler(int sig) {
    void *array[10];
    size_t size;
    char **strings;
    size_t i;

    /* Get backtrace */
    size = backtrace(array, 10);
    strings = backtrace_symbols(array, size);

    printf("Caught signal %d\n", sig);
    printf("Backtrace:\n");
    for (i = 0; i < size; i++) {
        printf("%s\n", strings[i]);
    }

    /* Free the memory allocated by backtrace_symbols */
    free(strings);
    exit(1);
}
static bool sigsegv_trace_enabled = false;
void enable_sigsegv_trace(){
    if(sigsegv_trace_enabled){
        return;
    }
    sigsegv_trace_enabled = true;
    struct sigaction sigact;
    sigact.sa_handler = sigsegv_handler;
    sigemptyset(&sigact.sa_mask);
    sigact.sa_flags = 0;
    sigaction(SIGSEGV, &sigact, NULL);
}

#ifndef kill
int kill(pid_t pid, int sig);
#endif

int ckill(int pid){
    return kill(pid,9);
}
