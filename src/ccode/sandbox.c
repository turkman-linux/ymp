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
#include <sys/prctl.h>

#ifndef clear_env
void clear_env();
#endif

#ifndef create_dir
void create_dir(const char *dir);
#endif

#ifndef which
char* which(char* path);
#endif


#ifndef info
char* info(char* message);
#endif

int sandbox_network = 0;
int sandbox_uid = 0;
int sandbox_gid = 0;

#ifndef get_bool
int get_bool(char* variable);
#endif

#ifndef get_builddir_priv
char* get_builddir_priv();
#endif

#ifndef operation_main_raw
int operation_main_raw(char* type, char** args);
#endif

int isdir(char* target);
int isfile(char* target);
void remove_all(char* target);

char* which(char* cmd);
void write_to_file(const char *which, const char *format, ...);
void sandbox_bind(char* dir);
void sandbox_bind_shared(char* dir);
void sandbox_create_tmpfs(char* dir);
void sandbox_mount_shared();

char* sandbox_shared;
char* sandbox_tmpfs;

char* sandbox_rootfs;

int sandbox(char* type, char** args){
    int flag = CLONE_NEWCGROUP | CLONE_NEWNS | CLONE_NEWUSER;
    if(isfile("/.sandbox")){
        exit(31);
    }
    pid_t pid = fork();
    if(pid == 0) {
        int r = prctl(PR_SET_PDEATHSIG, SIGHUP);
        if (r == -1){
            exit(1);
        }

        write_to_file("/proc/self/comm", "ymp-sandbox");
        uid_t uid = getuid();
        gid_t gid = getgid();
        unshare(flag);
        // remap uid
        write_to_file("/proc/self/uid_map", "%d %d 1", sandbox_uid, uid);
        // deny setgroups (see user_namespaces(7))
        write_to_file("/proc/self/setgroups", "deny");
        // remap gid
        write_to_file("/proc/self/gid_map", "%d %d 1", sandbox_gid, gid);
        sandbox_create_tmpfs("/tmp/ymp-root/");
        sandbox_bind("/usr");
        sandbox_bind("/etc");
        sandbox_bind("/bin");
        sandbox_bind("/lib");
        sandbox_bind("/lib64");
        sandbox_bind("/sbin");
        sandbox_bind("/var");
        sandbox_bind("/dev");
        sandbox_bind("/sys");
        sandbox_create_tmpfs("/tmp/ymp-root/root");
        sandbox_create_tmpfs("/tmp/ymp-root/tmp");
        sandbox_create_tmpfs("/tmp/ymp-root/run");
        sandbox_bind(get_builddir_priv());
        sandbox_bind("/proc/");
        char *token = strtok(sandbox_shared,":");
        while(token != NULL){
            sandbox_bind_shared(token);
            token = strtok(NULL,":");
        }
        token = strtok(sandbox_tmpfs,":");
        while(token != NULL){
            sandbox_bind_shared(token);
            token = strtok(NULL,":");
        }
        write_to_file("/tmp/ymp-root/.sandbox", "%d",getpid());
        if (0 == chroot("/tmp/ymp-root")){
            if(0 == chdir("/")){
                unshare(CLONE_NEWUTS);
                if(sandbox_network == 0){
                    unshare(CLONE_NEWNET);
                }
                unshare(CLONE_NEWIPC);
                unshare(CLONE_VM);
                unshare(CLONE_NEWPID| CLONE_VFORK | SIGCHLD);
                exit(operation_main_raw(type,args));
            }
        }
        exit(127);
        return 127;
    }else{
        int status;
        kill(wait(&status),9);
        remove_all("/tmp/ymp-root/");
        return status;
    }
}


void sandbox_bind(char* dir){
    char target[(strlen(dir)+20)*sizeof(char)];
    char source[(strlen(dir)+strlen(sandbox_rootfs)+20)*sizeof(char)];
    strcpy(target,"/tmp/ymp-root/");
    strcat(target,dir);
    strcpy(source,sandbox_rootfs);
    strcat(source,"/");
    strcat(source,dir);
    if(!isdir(target)){
        create_dir(target);
        mount(source, target, NULL, MS_SILENT | MS_BIND | MS_REC, NULL);
    }
}
void sandbox_bind_shared(char* dir){
    char target[(strlen(dir)+20)*sizeof(char)];
    strcpy(target,"/tmp/ymp-root/");
    strcat(target,dir);
    create_dir(target);
    mount(dir, target, NULL, MS_SILENT | MS_BIND | MS_REC, NULL);
}

void sandbox_create_tmpfs(char* dir){
    char source[(strlen(dir)+strlen(sandbox_rootfs)+10)*sizeof(char)];
    strcpy(source,sandbox_rootfs);
    strcat(source,"/");
    strcat(source,dir);
    create_dir(source);
    mount("tmpfs",source,"tmpfs",0,NULL);
}

#endif
