#ifndef _sandbox
#define _sandbox
#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <signal.h>
#include <stdio.h>
#include <stdarg.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/mount.h>

int sandbox_network = 0;
int sandbox_uid = 0;
int sandbox_gid = 0;

char* which(char* cmd);
void write_to_file(const char *which, const char *format, ...);
void bind_root(char* dir);
void create_tmpfs(char* dir);

int sandbox(char** args){
    int flag = CLONE_NEWCGROUP | CLONE_NEWNS | CLONE_NEWUSER;
    pid_t pid = fork();
    if(pid == 0) {
        uid_t uid = getuid();
        gid_t gid = getgid();
        unshare(flag);
        // remap uid
        write_to_file("/proc/self/uid_map", "%d %d 1", sandbox_uid, uid);
        // deny setgroups (see user_namespaces(7))
        write_to_file("/proc/self/setgroups", "deny");
        // remap gid
        write_to_file("/proc/self/gid_map", "%d %d 1", sandbox_gid, gid);
        mount("tmpfs","/root","tmpfs",0,NULL);
        bind_root("/usr");
        bind_root("/etc");
        bind_root("/bin");
        bind_root("/lib");
        bind_root("/lib64");
        bind_root("/etc");
        bind_root("/bin");
        bind_root("/sbin");
        bind_root("/var");
        bind_root("/dev");
        bind_root("/sys");
        bind_root("/proc");
        create_tmpfs("/root/root");
        create_tmpfs("/root/tmp");
        create_tmpfs("/root/run");

        if (0 == chroot("/root")){
            int t = chdir("/");
            unshare(CLONE_NEWUTS);
            if(sandbox_network == 0){
                unshare(CLONE_NEWNET);
            }
            unshare(CLONE_NEWIPC);
            unshare(CLONE_VM);
            _exit(execvpe(which(args[0]),args,NULL));
        }
        _exit(127);
        return 127;
    }else{
        int status;
        wait(&status);
        return status;
    }
}

void bind_root(char* dir){
    char target[(strlen(dir)+10)*sizeof(char)];
    strcpy(target,"/root/");
    strcat(target,dir);
    mkdir(target, 0755);
    mount(dir, target, 0, MS_BIND, NULL);
}

void create_tmpfs(char* dir){
    mkdir(dir, 0755);
    mount("tmpfs",dir,"tmpfs",0,NULL);
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
