//DOC: ## Ymp C source adaptations
//DOC: ### ttysize.c
//DOC: `void tty_size_init():`
//DOC: start tty size calculation
public extern void tty_size_init();
//DOC: `int get_tty_width():`
//DOC: return tty column size
public extern int get_tty_width ();
//DOC: `int get_tty_heigth():`
//DOC: return tty line size
public extern int get_tty_height ();

//DOC: ### which.c
//DOC: `string which(string cmd):`
//DOC: get command file location
public extern string which(string cmd);

//DOC: ### users.c
//DOC: `void switch_user(string username):`
//DOC: change current user
public extern void switch_user(string username);
//DOC: `int get_uid_by_user(string username):`
//DOC: get UID value from username
public extern int get_uid_by_user(string username);
//DOC: ` bool is_root():`
//DOC: chech root user
public extern bool is_root();

// ### nostd.c 
// All private functions. please look util/interface.vala
private extern void no_stdin();
private extern void no_stdout();
private extern void no_stderr();

//DOC: ### sandbox.c
//DOC: `void sandbox(string[] args):`
//DOC: run command in sandboxed area
public extern int sandbox(string[] args);
//DOC: `boot sandbox_network:`
//DOC: enable/disable sandbox network access (default: false)
public extern bool sandbox_network;
//DOC: `void sandbox_bind(string path):`
//DOC: bind directory to sandboxed environment
public extern string sandbox_shared;
public extern string sandbox_rootfs;
//DOC: `int sandbox_uid:`
//DOC: sandbox user uid value (default: 0)
public extern int sandbox_uid;
//DOC: `int sandbox_gid:`
//DOC: sandbox user gid value (default: 0)
public extern int sandbox_gid;

//DOC: ### archive-create.c
//DOC: `void write_archive(string output,string[] files):`
//DOC: create archive file
//this functions and values used by util/archive.vala
public extern void write_archive(string output,string[] files);
private extern int afilter;
private extern int aformat;

//DOC: ### file.c
//DOC: `int filesize(string path):`
//DOC: calculate file size
public extern int filesize(string path);
//DOC: `string getArch():`
//DOC: get current cpu architecture
public extern string getArch();
//DOC: `void sync():`
//DOC: sync call
public extern void fs_sync();
//DOC: `void create_dir(string path):`
//DOC: create directory from path
public extern void create_dir(string path);
//DOC: `string readfile_raw (string path):`
//DOC: Read file from **path** and return content
public extern string readfile_raw(string path);
//DOC: `bool isdir(string path):`
//DOC: Check **path** is directory
public extern bool isdir(string path);
//DOC: `bool issymlink(string path)`:
//DOC: check path is symlink
public extern bool issymlink(string path);

//DOC: ### signal.c
//DOC: `void block_sigint():`
//DOC: block ctrl-c
public extern void block_sigint();

//DOC: ### process.c
//DOC: `void single_instance():`
//DOC: block multiple process
public extern void single_instance();
//DOC: `int run(string command):`
//DOC: run command.
public extern int run (string command);
//DOC: `long get_epoch():`
//DOC: get epoch time
public extern long get_epoch();
private extern int ckill(int pid);

//DOC: `int run_silent(string command):`
//DOC: run command silently.
public extern int run_silent (string command);

//DOC: `int run_args(string[] args):`
//DOC: ruh command from argument array
public extern int run_args(string[] args);


//DOC; ### fetcher.c
//DOC: `bool fetch(string url, string path):`
//DOC: fetch file from url
//DOC: `string fetch_string(string url):`
//DOC: fetch string from url
#if no_libcurl
#else
public extern bool fetch(string url, string path);
public extern string fetch_string(string url);
#endif

//DOC: ### string.c
//DOC: `string run_printf(char* format, ...):`
//DOC: run command like printf
public extern string run_printf(char* format, ...);
private extern string ccolorize(string message, string color);
public extern void csort(string[] arr, int n);

//DOC:// ### logger.c
//DOC: `void print_fn(string message, bool new_line, bool err):`
//DOC: Main print function. Has 3 arguments
//DOC: * message: log message
//DOC: * new_line: if set true, append new line
//DOC: * err: if set true, write log to stderr
public extern void print_fn(string message, bool new_line, bool err);
private extern void cprint(string message);
private extern void cprint_stderr(string message);
private extern void cprint_dummy(string message);
