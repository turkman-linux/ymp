#ifndef _sandbox
#define _sandbox
#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <signal.h>
#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <sys/prctl.h>

#include <value.h>

#include <glib.h>

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

#ifdef DEBUG
char* debug(char* message);
#endif

int sandbox_network = 1;
int sandbox_uid = 0;
int sandbox_gid = 0;

#ifndef get_builddir_priv
char* get_builddir_priv();
#endif

#ifndef operation_main
gint operation_main(const gchar* type, gchar** args, gint length);
#endif

int isdir(char* target);
int isfile(char* target);
void remove_all(char* target);
char* str_add(char* str1, char* str2);

char* which(char* cmd);
void write_to_file(const char *which, const char *format, ...);
void sandbox_bind(char* dir);
void sandbox_bind_shared(char* dir);
void sandbox_create_tmpfs(char* dir);
void sandbox_mount_shared();

char* sandbox_shared;
char* sandbox_tmpfs;

char* sandbox_rootfs;

char** get_envs();

gint sandbox(const gchar* type, gchar** args, gint length){
    (void)length;
    if(sandbox_rootfs == NULL){
        sandbox_rootfs = "/";
    }
    if(sandbox_shared == NULL){
        sandbox_shared = "";
    }
    int flag = CLONE_NEWCGROUP | CLONE_NEWNS | CLONE_NEWUSER | CLONE_NEWPID | CLONE_NEWUTS;
    if(isfile("/.sandbox")){
        return operation_main(type,args, length);
    }
    pid_t pid = fork();
    #if DEBUG
    debug("Sandbox: fork");
    #endif
    if(pid == 0) {
        int r = prctl(PR_SET_PDEATHSIG, SIGHUP);
        if (r == -1){
            exit(1);
        }

        write_to_file("/proc/self/comm", "ymp-sandbox");
        uid_t uid = getuid();
        gid_t gid = getgid();
        unshare(flag);
        int pid = fork();
        if (pid != 0) {
            int status;
            waitpid(-1, &status, 0);
            exit(status);
        }
        /* set new hostname */
        sethostname("ymp-sandbox", 11);
        /* remap uid */
        write_to_file("/proc/self/uid_map", "%d %d 1", sandbox_uid, uid);
        /* deny setgroups (see user_namespaces(7)) */
        write_to_file("/proc/self/setgroups", "deny");
        /* remap gid */
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
        /* isolate /proc */
        create_dir("/tmp/ymp-root/proc/");
        if (mount("proc", "/tmp/ymp-root/proc", "proc", MS_NOSUID|MS_NOEXEC|MS_NODEV, NULL)) {
            printf("Cannot mount proc! errno=%i\n", errno);
            exit(1);
        }

        char *token = strtok(sandbox_shared,":");
        while(token != NULL){
            sandbox_bind_shared(token);
            token = strtok(NULL,":");
        }
        token = strtok(sandbox_tmpfs,":");
        char* target = NULL;
        while(token != NULL){
            target = calloc((strlen(token)+15), sizeof(char));
            strcpy(target,"/tmp/ymp-root/");
            strcat(target,token);
            sandbox_create_tmpfs(target);
            token = strtok(NULL,":");
            free(target);
        }
        write_to_file("/tmp/ymp-root/.sandbox", "%d",getpid());
        if (0 == chroot("/tmp/ymp-root")){
            #if DEBUG
            debug("Sandbox: chroot /tmp/ymp-root");
            #endif
            if(0 == chdir("/")){
                #if DEBUG
                debug("Sandbox: chdir /");
                #endif
                unshare(CLONE_NEWUTS);
                if(sandbox_network == 0){
                    unshare(CLONE_NEWNET);
                }
                unshare(CLONE_NEWIPC);
                unshare(CLONE_VM);
                unshare(CLONE_VFORK | SIGCHLD);
                #if DEBUG
                debug(str_add("Sandbox: execute ", type));
                #endif
                int cur = 0;
                while(args[cur]){
                    cur++;
                }
                char** new_args = calloc(cur+2, sizeof(char*));
                cur = 0;
                while(args[cur]){
                    new_args[cur] = args[cur];
                    cur++;
                }
                if(getenv("TERM") == NULL){
                    setenv("TERM", "linux", 1);
                }
                exit(operation_main(type,new_args, cur));
                /*exit(execvpe("/proc/self/exe",new_args,get_envs())); */
                #if DEBUG
                debug(str_add("Sandbox: execute done", type));
                #endif
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
    #ifdef DEBUG
    debug(str_add("Sandbox: create bind", dir));
    #endif
    char *target = calloc((strlen(dir)+15), sizeof(char));
    strcpy(target,"/tmp/ymp-root/");
    strcat(target,dir);

    char *source = calloc(strlen(dir)+strlen(sandbox_rootfs)+2, sizeof(char));
    strcpy(source,sandbox_rootfs);
    strcat(source,"/");
    strcat(source,dir);

    if(!isdir(target)){
        create_dir(target);
        mount(source, target, NULL, MS_SILENT | MS_BIND | MS_REC, NULL);
    }
}
void sandbox_bind_shared(char* dir){
    #if DEBUG
    debug(str_add("Sandbox: bind shared ", dir));
    #endif
    char *target = calloc((strlen(dir)+15), sizeof(char));
    strcpy(target,"/tmp/ymp-root/");
    strcat(target,dir);
    create_dir(target);
    mount(dir, target, NULL, MS_SILENT | MS_BIND | MS_REC, NULL);
}

void sandbox_create_tmpfs(char* dir){
    #if DEBUG
    debug(str_add("Sandbox: create tmpfs ", dir));
    #endif
    char *source = calloc(strlen(dir)+strlen(sandbox_rootfs)+2, sizeof(char));
    strcpy(source,sandbox_rootfs);
    strcat(source,"/");
    strcat(source,dir);
    create_dir(source);
    mount("tmpfs",source,"tmpfs",0,NULL);
}

#endif
