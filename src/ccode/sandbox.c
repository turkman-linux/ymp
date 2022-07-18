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

void create_dir(const char *dir);

int sandbox_network = 0;
int sandbox_uid = 0;
int sandbox_gid = 0;

char* which(char* cmd);
void write_to_file(const char *which, const char *format, ...);
void sandbox_bind(char* dir);
void sandbox_bind_shared(char* dir);
void sandbox_create_tmpfs(char* dir);
void sandbox_mount_shared();

char* sandbox_shared;

char* sandbox_rootfs;

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
        sandbox_bind("/usr");
        sandbox_bind("/etc");
        sandbox_bind("/bin");
        sandbox_bind("/lib");
        sandbox_bind("/lib64");
        sandbox_bind("/etc");
        sandbox_bind("/bin");
        sandbox_bind("/sbin");
        sandbox_bind("/var");
        sandbox_bind("/dev");
        sandbox_bind("/sys");
        sandbox_bind("/proc");
        sandbox_create_tmpfs("/root/root");
        sandbox_create_tmpfs("/root/tmp");
        sandbox_create_tmpfs("/root/run");
        sandbox_bind_shared(sandbox_shared);
        if (0 == chroot("/root")){
            if(0 == chdir("/")){
                unshare(CLONE_NEWUTS);
                if(sandbox_network == 0){
                    unshare(CLONE_NEWNET);
                }
                unshare(CLONE_NEWIPC);
                unshare(CLONE_VM);
                setenv("PATH","/bin:/usr/bin:/sbin:/usr/sbin",1);
                setenv("TERM","linux",1);
                _exit(execvpe(which(args[0]),args,NULL));
            }
        }
        _exit(127);
        return 127;
    }else{
        int status;
        wait(&status);
        return status;
    }
}

void sandbox_bind(char* dir){
    char target[(strlen(dir)+10)*sizeof(char)];
    char source[(strlen(dir)+strlen(sandbox_rootfs)+10)*sizeof(char)];
    strcpy(target,"/root/");
    strcat(target,dir);
    strcpy(source,sandbox_rootfs);
    strcat(source,"/");
    strcat(source,dir);
    create_dir(target);
    mount(source, target, NULL, MS_SILENT | MS_BIND | MS_REC, NULL);
}
void sandbox_bind_shared(char* dir){
    char target[(strlen(dir)+10)*sizeof(char)];
    strcpy(target,"/root/");
    strcat(target,dir);
    create_dir(target);
    mount(dir, target, NULL, MS_SILENT | MS_BIND | MS_REC, NULL);
}

void sandbox_create_tmpfs(char* dir){
    char source[(strlen(dir)+strlen(sandbox_rootfs)+10)*sizeof(char)];
    strcpy(source,sandbox_rootfs);
    strcat(source,"/");
    strcat(source,dir);
    
    mount("tmpfs",source,"tmpfs",0,NULL);
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
