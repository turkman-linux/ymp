#include <pthread.h>

typedef struct _job {
    void (*callback)(void*,...);
    void* args;
    void* ctx;
    int id;
} job;

typedef struct _jobs {
    job* jobs;
    int max;
    int current;
    int parallel;
    int finished; /* Track the number of finished jobs */
    int total;    /* Total number of jobs */
    pthread_cond_t cond;   /* Condition variable for signaling job completion */
} jobs;

#define MAX_JOB 1024*1024
#define JOB_PARALLEL 8
void jobs_unref(jobs *j);
void jobs_add(jobs* j, void (*callback)(void*,...),  void* ctx, void* args, ...);
void jobs_run(jobs* j);
jobs* jobs_new();
