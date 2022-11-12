#include <signal.h>
void block_sigint(){
    signal(SIGINT, SIG_IGN);
}

int ckill(int pid){
    return kill(pid,9);
}
