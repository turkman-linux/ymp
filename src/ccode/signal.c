#include <signal.h>
void block_sigint(){
    signal(SIGINT, SIG_IGN);
}