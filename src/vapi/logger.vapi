[CCode (cheader_filename = "logger.h")]
public void print(string msg);

[CCode (cheader_filename = "logger.h")]
public void warning(string msg);

#if DEBUG
[CCode (cheader_filename = "logger.h")]
public void debug(string msg);

[CCode (cheader_filename = "logger.h")]
public void debug_fn (string message);
#endif

[CCode (cheader_filename = "logger.h")]
public void info(string msg);

[CCode (cheader_filename = "logger.h")]
public void print_stderr(string msg);

[CCode (cheader_filename = "logger.h")]
public void warning_fn (string message);

[CCode (cheader_filename = "logger.h")]
public void info_fn (string message);

[CCode (cheader_filename = "logger.h")]
public void logger_init ();

[CCode (cheader_filename = "logger.h")]
public void set_terminal_title (string message);
