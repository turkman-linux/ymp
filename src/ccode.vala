//DOC: ## Inary C source adaptations
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
public extern void create_dir(string path);
