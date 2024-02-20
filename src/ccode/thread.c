#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

pthread_t thread_id[1024];

static size_t _cur = 0;
size_t _max = 5;

void thread_start();
void thread_add(void *(*fn)(void *), void* args);

void thread_add(void *(*fn)(void *), void* args) {
    pthread_create(&thread_id[_cur], NULL, fn, args);
    _cur++;
    if(_cur > _max - 1){
        thread_start();
    }
}
void thread_start(){
    while(_cur>0){
        _cur--;
	      pthread_join(thread_id[_cur], NULL);
    }
}

