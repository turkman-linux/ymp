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

