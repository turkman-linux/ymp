## logging functions
`void print_fn(string message, bool new_line, bool err):`

Main print function. Has 3 arguments

* message: log message
* new_line: if set true, append new line
* err: if set true, write log to stderr
`void print(string message):`

write standard messages to stdout

Example usage:

```vala
print("Hello world!"); 
```

`void print_stderr(string message):`

same with print but write to stderr

`void warning(string message):`

write warning message like this:

```yaml
WARNING: message
```

`void debug(string message):`

write debug messages. Its only print if debug mode enabled.

`void error(int status):`

print error message and exit if error message list not empty and status is not 0.

This function clear error message list.

This funtion must run after **error_add(string message)**

Example usage:

```vala
if(num == 12){
    error_add("Number is not 12."); 
}
error(1); 
```

`void error_add(string message):`

add error message to error message list

## class archive()
Load & extract archive files.

Example usage:

```vala 
var tar = new archive(); 
tar.load("/tmp/archive.tar.gz"); 
tar.extract_all(); 
```

`void archive.load(string path):`

load archive file from **path**

`string[] archive.list_files():`

Get archive file list

`void archive.set_target(string path):`

Change target directory for extract

`void archive.extract(string path):`

Extract **path** file to target directory

`void archive.extract_all()`

Extract all files to target

## ini parser
ini parser library for libinary

ini_variable and ini_section classes are struct. inifile class is actual parser.

### class ini_variable()
struct for ini variables

Example usage:

```vala
var inivar = new ini_variable(); 
inivar.name = "colorize"; 
inivar.value = "false"; 
```

`string ini_variable.name`

`string ini_variable.value`

### class ini_section()
struct for ini sections
Example usage:

```vala
var inisec = new ini_section(); 
inisec.add("debug","false"); 
...
stdout.printf(inisec.name); 
```

`string ini_section.name:`

ini section name

`void ini_section.add(string variable, string value):`

add ini_variable into ini_section

`string ini_section.get(string name):`

get ini_variable value by variable name
`string[] ini_section.get_variables():`
return ini_variable names in ini_section
### class inifile()
ini file parser

Example usage:

``` vala
var ini = new inifile(); 
ini.load("/etc/inary.conf")

var is_debug =  (ini.get("inary", "debug") == "true"); 
```

`void inifile.load(string path):`

load ini file from **path**

`string inifile.get(string name, string variable):`

get value from ini file by section name and variable name.

`string[] inifile.get_variables(string name):`

get variable names by section name

`string[] inifile.get_sections():`

get section names from ini

`string inifile.dump():`

print inifile data

## File functions
File & Directory functions

`string readfile_raw (string path):`

Read file from **path** and return content

`string readfile(string path):`

read file from **path** and remove commends

`void cd(string path):`

change current directory to **path**

`string pwd():`

return current directory path
`int create_dir(string path)`

create **path** directory

`int remove_dir(string path)`

remove **path** directory

`int remove_file(string path)`

remove **path** file

`string[] listdir(string path):`

list directory content and result as array

`bool isfile(string path):`

Check **path** is file

## Interface functions
User interaction functions

Example usege:

```vala
if(yesno("Do you want to continue?")){ 
    ... 
} else { 
    stderr.printf("Operation canceled."); 
} 
```

`bool yesno(string message):`

Create a yes/no question.

## Command functions
This functions call shell commands

Example usage:
```vala
if (0 != run("ls /var/lib/inary")){ 
    stdout.printf("Command failed"); 
} 
string uname = getoutput("uname"); 
```

`string getoutput (string command):`

Run command and return output

**Note:** stderr ignored.

`int run_silent(string command):`

run command silently.

`int run(string command):`

run command.

