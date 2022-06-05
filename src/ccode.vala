//DOC: ## Inary C source adaptations
//DOC: ### ttysize.c
//DOC: `void tty_size_init():`;
//DOC: start tty size calculation;
public extern void tty_size_init();
//DOC: `int get_tty_width():`;
//DOC: return tty column size;
public extern int get_tty_width ();
//DOC: `int get_tty_heigth():`;
//DOC: return tty line size;
public extern int get_tty_height ();
//DOC: ### which.c
//DOC: `string which(string cmd):`;
//DOC: get command file location;
public extern string which(string cmd);
//DOC: ### users.c
//DOC: `void switch_user(string username):`;
//DOC: change current user.
public extern void switch_user(string username);
//DOC: `int get_uid_by_user(string username):`;
//DOC: get UID value from username;
public extern int get_uid_by_user(string username);
//DOC: ` bool is_root():`;
//DOC: chech root user;
public extern bool is_root();
