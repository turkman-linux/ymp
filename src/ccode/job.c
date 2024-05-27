#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pthread.h>
#include <string.h>
#include <stdarg.h>

#include <jobs.h>

static void* worker_thread(void* arg) {
    jobs* j = (jobs*)arg;
    while (1) {
        if (j->finished >= j->total) {
            break;
        }
        int i;
        bool e = false; /* search for job */
        for (i = 0; i < j->total; ++i) {
            if (j->jobs[i].callback != NULL) {
                void (*callback)(void*, ...) = j->jobs[i].callback;
                j->jobs[i].callback = NULL;
                callback((void*)j->jobs[i].ctx, (void*)j->jobs[i].args);
                j->finished++;
                j->current--;
                e = true;
                break;
            }
        }
        if(!e){
            break;
        }
    }
    pthread_exit(NULL);
}

void jobs_unref(jobs *j) {
    free(j->jobs);
    pthread_cond_destroy(&j->cond);
    free(j);
}

void jobs_add(jobs* j, void (*callback)(void*, ...), void* ctx, void* args, ...) {
    if (j->total < j->max) {
        job new_job;
        new_job.callback = callback;
        new_job.args = args;
        new_job.ctx = ctx;
        new_job.id = j->total;
        j->jobs[j->total++] = new_job;
        j->current++;
        pthread_cond_signal(&j->cond);
    }
}

void jobs_run(jobs* j) {
    pthread_t* threads = (pthread_t*)malloc(j->parallel * sizeof(pthread_t));
    int i;
    for (i = 0; i < j->parallel; ++i) {
        pthread_create(&threads[i], NULL, worker_thread, (void*)j);
    }
    for (i = 0; i < j->parallel; ++i) {
        pthread_join(threads[i], NULL);
    }
    free(threads);
}

jobs* jobs_new() {
    jobs* j = (jobs*)malloc(sizeof(jobs));
    j->max = MAX_JOB;
    j->current = 0;
    j->finished = 0;
    j->total = 0;
    j->parallel = JOB_PARALLEL;
    j->jobs = (job*)malloc(j->max * sizeof(job));
    pthread_cond_init(&j->cond, NULL);
    return j;
}
