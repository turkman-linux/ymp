#include <stddef.h>
#include <signal.h>
typedef void (*sighandler_t)(int);
sighandler_t sigint_signal;

void block_sigint(){
    sigint_signal = signal(SIGINT, SIG_IGN);
}

void unblock_sigint(){
   signal(SIGINT, sigint_signal);
}

int ckill(int pid){
    return kill(pid,9);
}
