#include <stdlib.h>

int main(int argc, char** argv, char** envp);
void __libc_start_main(int argc, char** argv, char** envp){
    exit(main(argc, argv, envp));
}
