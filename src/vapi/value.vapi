[CCode (cheader_filename = "value.h")]
public string get_value(string name);

[CCode (cheader_filename = "value.h")]
public void set_value(string name, string value);

[CCode (cheader_filename = "value.h")]
public void set_value_readonly(string name, string value);

[CCode (cheader_filename = "value.h")]
public string[] get_variable_names();

[CCode (cheader_filename = "value.h")]
public bool get_bool(string name);

[CCode (cheader_filename = "value.h")]
public void set_bool(string name, bool value);


