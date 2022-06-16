#ifndef _sandbox
#define _sandbox
#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <signal.h>
#include <stdio.h>
#include <stdarg.h>
#include <fcntl.h>

char* which(char* cmd);
void write_to_file(const char *which, const char *format, ...);

void sandbox(char** args){
    int flag = CLONE_NEWCGROUP | CLONE_NEWNS | CLONE_NEWUSER;
    pid_t pid = fork();
    if(pid == 0) {
        uid_t uid = getuid();
        gid_t gid = getgid();
        unshare(flag);
        // remap uid
        write_to_file("/proc/self/uid_map", "0 %d 1", uid);
        // deny setgroups (see user_namespaces(7))
        write_to_file("/proc/self/setgroups", "deny");
        // remap gid
        write_to_file("/proc/self/gid_map", "0 %d 1", gid);
        unshare(CLONE_NEWPID);
        unshare(CLONE_NEWUTS);
        unshare(CLONE_NEWNET);
        unshare(CLONE_NEWIPC);
        unshare(CLONE_VM);
        chroot("/");
        mount("tmpfs", "/home", "tmpfs", 0, NULL);
        mount("tmpfs", "/root", "tmpfs", 0, NULL);

        execvpe(which(args[0]),args,NULL);
    }
    waitpid(pid, NULL, 0);
}

void write_to_file(const char *which, const char *format, ...) {
  FILE * fu = fopen(which, "w");
  va_list args;
  va_start(args, format);
  if (vfprintf(fu, format, args) < 0) {
    printf("cannot write");
  }
  fclose(fu);
}
#endif
