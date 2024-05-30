#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pthread.h>
#include <string.h>
#include <stdarg.h>

#include <jobs.h>
#include <logger.h>

typedef struct _worker_job {
    jobs* j;
    int id;
} worker_job;

static void* worker_thread(void* arg) {
    worker_job* jb= (worker_job*)arg;
    jobs *j = jb->j;
    int i;
    for (i = jb->id; i < j->total; i+=j->parallel) {
        fdebug("Run job: %d\t%d\t\t%d\t%d\n", j->total, j->parallel, i, jb->id);
        j->jobs[i].callback((void*)j->jobs[i].ctx, (void*)j->jobs[i].args);
        j->finished++;
    }
    return NULL;
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
        fdebug("Add job:%d\t%d\t%d\n", j->total, j->max, j->parallel);
    }
}

void jobs_run(jobs* j) {
    pthread_t* threads = (pthread_t*)calloc(j->parallel, sizeof(pthread_t));
    int i;
    for (i = 0; i < j->parallel; ++i) {
        worker_job *jb = (worker_job*)calloc(1,sizeof(worker_job));
        jb->j = j;
        jb->id = i;
        pthread_create(&threads[i], NULL, worker_thread, (void*)jb);
    }
    for (i = 0; i < j->parallel; ++i) {
        pthread_join(threads[i], NULL);
    }
    fdebug("Done jobs:%d\t%d\t%d\n", j->finished, j->max, j->parallel);
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
    fdebug("New jobs");
    return j;
}
