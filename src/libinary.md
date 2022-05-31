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

## command functions
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

