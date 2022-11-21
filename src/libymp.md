# src/ccode.vala
## Ymp C source adaptations

### ttysize.c

`void tty_size_init():`

start tty size calculation

`int get_tty_width():`

return tty column size

`int get_tty_heigth():`

return tty line size

### which.c

`string which(string cmd):`

get command file location

### users.c

`void switch_user(string username):`

change current user

`int get_uid_by_user(string username):`

get UID value from username

` bool is_root():`

chech root user

### sandbox.c

`void sandbox(string[] args):`

run command in sandboxed area

`boot sandbox_network:`

enable/disable sandbox network access (default: false)

`void sandbox_bind(string path):`

bind directory to sandboxed environment

`int sandbox_uid:`

sandbox user uid value (default: 0)

`int sandbox_gid:`

sandbox user gid value (default: 0)

### archive-create.c

`void write_archive(string output,string[] files):`

create archive file

### file.c

`int filesize(string path):`

calculate file size

`string getArch():`

get current cpu architecture

`void sync():`

sync call

`void create_dir(string path):`

create directory from path

`string readfile_raw (string path):`

Read file from **path** and return content

`bool isdir(string path):`

Check **path** is directory

`bool issymlink(string path)`:

check path is symlink

### signal.c

`void block_sigint():`

block ctrl-c

### process.c

## Command functions

This functions call shell commands

Example usage

```vala

if (0 != run("ls /var/lib/ymp")){

    stdout.printf("Command failed");

}

string uname = getoutput("uname");

```

`void single_instance():`

block multiple process

`int run(string command):`

run command.

`long get_epoch():`

get epoch time

`string getoutput (string command):`

Run command and return output

**Note:** stderr ignored.

`int run_silent(string command):`

run command silently.

`int run_args(string[] args):`

ruh command from argument array

`bool fetch(string url, string path):`

fetch file from url

`string fetch_string(string url):`

fetch string from url

### string.c

`string run_printf(char* format, ...):`

run command like printf

//DOC:// ### logger.c

`void print_fn(string message, bool new_line, bool err):`

Main print function. Has 3 arguments

* message: log message

* new_line: if set true, append new line

* err: if set true, write log to stderr

# src/color.vala
## Colors

Available colors

black, red, green, yellow, blue, magenta, cyan, white

# src/data/dependency.vala
## Dependency analysis

resolve dependencies

`string[] resolve_dependencies(string[] names):`

return package name list with required dependencies

`string[] resolve_reverse_dependencies(string[] names):`

return package name list with required reverse dependencies

# src/data/package.vala
## class package

ymp package struct & functions

Example usage:

```vala

var pkg = new package();

pkg.load_from_archive("/tmp/bash-5.0-x86_64.ymp");

stdout.printf(pkg.get("archive-hash"));

foreach(string pkgname in pkg.dependencies){

    stdout.printf(pkgname);

}

var pkg2 = new package();

pkg2.load("/tmp/metadata.yaml");

if(pkg2.is_installed()){

    stdout.printf(pkg2+" installed");

}

```

`void package.load(string path):`

Read package information from metadata file

`void package.load_from_data(string data):`

Read package information from string data

`void package.load_from_archive(string path):`

Read package information from ymp file

`string[] package.list_files():`

return ymp package files list

`string[] package.list_files():`

return ymp package files list

`string[] package.gets(string name):`

Get package array value

`string package.get(string name):`

Get package value

`string package.get_uri():`

get repository uri

`void package.download():`

download package file from repository

`void package.extract():`

extract package to quarantine directory

quarantine directory is **get_storage()+"/quarantine"**;

Example ymp archive format:

```yaml

package.ymp

  ├── data.tar.gz

  │     ├ /usr

  │     │  └ ...

  │     └ /etc

  │        └ ...

  ├── files

  └── metadata.yaml

```

* **metadata.yaml** file is package information data.

* **files** is file list

* **data.tar.gz** in package archive

`void package.build():`

build source code into buildpath

`bool package.is_installed():`

return true if package is installed

## Miscellaneous package functions

package functions outside package class

`string[] list_installed_packages():`

return installed package names array

`package get_installed_package(string name):`

get package object from installed package name

`bool is_installed_package():`

return true if package installed

# src/data/quarantine.vala
`void quarantine_reset():`

remove quarantine directories and create new ones

`bool quarantine_validate_files():`

check quarantine file hashes

`void quarantine_install():`

install quarantine files to rootfs

# src/data/repository.vala
## class repository

repository object to list or select packages from repository

Example usage:

```vala

var repo = new repository();

repo.load("main.yaml");

if(repo.has_package("bash")){

    stdout.printf("Package found.");

}

foreach(string name in repo.list_packages()){

    package pkg = repo.get_package(name);

    stdout.printf(pkg.version);

}

```

`void repository.load(string repo_name):`

load repository data from repo name

`bool repository.has_package(string name):`

return true if package exists in repository

`package repository.get_source(string name):`

get package object from repository by source name

`package repository.get_package(string name):`

get package object from repository by package name

`string[] repository.list_packages():`

get all available package names from repository

`string[] repository.list_sources():`

get all available source names from repository

## Miscellaneous repository functions

repository functions outside repository class

`repository[] get_repos():`

get all repositories as array

`bool is_available_package(string name):`

return true if package is available

`package get_package_from_repository(string name):`

get package object from all repositories

`package get_source_from_repository(string name):`

get source package object from all repositories

`package get_from_repositony(stning name):`

return package if no-emerge else return source

`package get_package_from_file(string path):`

get package object from ymp file archive

`string[] get_repo_address():`

return repository adress list

`void update_repo():`

update local repository index

`string create_index_data(string fpath):`

generate remote repository index data

# src/data/ympbuild.vala
## ympbuild file functions.

ymp uses ympbuild format.

`void set_ympbuild_srcpath(string path):`

configure ympbuild file directory

`void set_ympbuild_srcpath(string path):`

configure ympbuild file directory

`string get_ympbuild_value(string variable):`

get a variable from ympbuild file

`string[] get_ympbuild_array(string variable):`

get a array from ympbuild file

`bool ympbuild_has_function(string function):`

check ympbuild file has function

`int run_ympbuild_function(string function):`

run a build function from ympbuild file

`string get_ympbuild_metadata():`

generate metadata.yaml content and return as string

# src/settings.vala
## Settings functions

ymp configuration functions

`string get_config(string section,string path):`

get config variable from ymp config

`void set_destdir(string rootfs):`

change distdir

`string get_storage():`

get ymp storage directory. (default: /var/lib/ymp)

`string get_configdir():`

get ymp storage directory. (default: /etc/)

`string get_storage():`

get ymp storage directory. (default: /var/lib/ymp)

`void set_config(string path):`

change ymp config file (default /etc/ymp.yaml)

# src/util/archive.vala
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

`bool is_archive(string path):`

check file is archive

`string[] archive.list_files():`

Get archive file list

`void archive.set_target(string path):`

Change target directory for extract

`void archive.add(string path):`

Add a file to archive create list

`void archive.create():`

Create archive.

`void archive.extract(string path):`

Extract **path** file to target directory

`string archive.readfile(string path):`

Read **path** file to target directory

`void archive.extract_all()`

Extract all files to target

# src/util/array.vala
## class array

fast and easy usable array library

Example usage:

```vala

var a = new array();

a.add("item1");

string[] b = {"item2","item3"};

a.adds(b);

a.remove("item2");

a.insert("item4",2);

string[] aa = a.get();

a.pop(0);

```

`void reverse():`

reverse array order

`void add(string item):`

add item into array

`void adds(string[] arr):`

add item list into array

`void remove(string item):`

remove item from array

`void pop(int index):`

remove item from array by index number

`void insert(string item, int index):`

insert item into array by number

`bool has(string item):`

check item exists in array

`string[] get():`

return as string array

`void set(string[] new_a):`

replace with new array

`long size()`;

return array length

# src/util/fetcher.vala
# src/util/file.vala
## File functions

File & Directory functions

`string readfile_byte(string path, long size):`

read **n** byte from file

`string readfile(string path):`

read file from **path** and remove commends

`void writefile(string path, string ctx):`

write **ctx** data to **path** file

`string safedir(string dir):`

directory safe for httpd

`void cd(string path):`

change current directory to **path**

`string pwd():`

return current directory path

`int remove_dir(string path)`

remove **path** directory

`int remove_file(string path)`

remove **path** file

`int remove_all(string path):`

Remove files and directories (like **rm -rf**)

`void move_file(stirg src, string desc):`

move **src** file to **desc**

`void copy_file(string src, string desc):`

copy **src** file to **desc**. File permissions and owners are ignored.

`string[] listdir(string path):`

list directory content and result as array

`bool iself(string path):`

return true if file is elf binary

`bool is64bit(string path):`

return true if file is elf binary

`bool isfile(string path)`:

check path is file

`string srealpath(string path):`

safe realpath function.

`string[] find(string path):`

find file and directories with parents

`string calculate_sha1sum(string path):`

calculate sha1sum value from file path

`string calculate_md5sum(string path):`

calculate md5sum value from file path

`string calculate_checksum(string path, ChecksumType type):`

calculate checksum value from file path and checksum type

# src/util/gpg.vala
# sign & verify file

`void sign_file(string path):`

sign a file with gpg key

`bool verify_file(string path):`

verify a file with gpg signature

`void sign_elf(string path):`

create gpg signature and insert into elf binary

`bool verify_elf(string path):`

dump gpg signature from file and verify elf file

# src/util/interface.vala
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

`void print_array(string[] array):`

print string array to fit terminal size

`void shitcat(string data):`

print data with shitty random colors.

`void print_with_cow(string data):`

print message with cow dialog

`void nostdin():`

close stdin. Ignore input. This function may broke application.

`void nostdout():`

close stdout

`void nostderr():`

close stderr

`void nostd():`

close stdin, stdout and stderr

# src/util/logger.vala
## logging functions

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

`void info(string message):`

write additional info messages.

`string colorize(string message, int color):`

Change string color if no_color is false.

Example usage:

```vala

var msg = colorize("Hello",red);

var msg2 = colorize("world",blue);

stdout.printf(msg+" "+msg2);

```

`void set_terminal_title(string msg):`

set terminal title

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

# src/util/string.vala
## String functions

easy & safe string operation functions.

`string join(string f, string[] array):`

merge array items. insert **f** in between

Example usage:

```vala

string[] aa = {"hello","world","!"};

string bb = join(aa," ");

stdout.printf(bb);

```

`string[] ssplit(string data, string f):`

safe split function. If data null or empty return empty array.

if **f** not in data, return single item array.

`string trim(string data):`

fixes excess indentation

`int count_tab(string line):`

count indentation level

`boot startswith(string data, string f):`

return true if data starts with f

`bool endswith(string data, string f):`

return true if data ends with f

`string sbasename(string path):`

safe basename. return filename

`string sdirname(string path):`

safe dirname. return path name

# src/util/value.vala
## Variable functions

set or get ymp global variable

Example usage:

```vala

set_value("CFLAGS","-O3");

var jobs = get_value("jobs");

if(get_bool("debug")){

    stderr.printf("Debug mode enabled");

}

```

`void set_value(string name, string value):`

add a global ymp variable as string

`string get_value(string name):`

get a ymp global variable as string

big names are read only and only defined by ymp

`bool get_bool(string name):`

get a ymp global variable as bool

`void set_bool(string name, bool value):`

add a global ymp variable as bool

`string[] list_values():`

return array of all ymp global value names

`void set_env(string variable, string value):`

add environmental variable

`string get_env(string variable):`

get a enviranmental variable

`string get_home():`

get home directory location

`void clear_env():`

remove all environmental variable except **PATH**

# src/util/yamlparser.vala
## Yaml parser

yaml file parser library for ymp

Example usage:

```vala

var yaml = new yamlfile();

yaml.load("/var/lib/ymp/metadata/bash.yaml");

var pkgarea = yaml.get("ymp.package");

var name = yaml.get_value(pkgarea,"name");

if(yaml.has_area(pkgarea,"dependencies")){

    dependencies = yaml.get_array(pkgarea,"dependencies");

}

```

`string yamlfile.data:`

Yaml file content

`void yamlfile.load(string path):`

load yaml from file

`string yamlfile.get(string path):`

get area from yaml content

`bool yamlfile.has_area(string fdata, string path):`

return true if **fdata** has **path** area

`string[] yamlfile.get_area_list(string fdata, string path):`

list all areas the name is **path**

`string yamlfile.get_value(string data, string name):`

get value from area data

`string[] yamlfile.get_array(string data, string name):`

get array from area data

`string yamlfile.get_area(string data, string path):`

get area from data

# src/wslblock.vala
## WSL shit bloker

detect & block WSL

`void wsl_block():`

If runs on WSL shit write fail message and exit :)

# src/ymp.vala
## class Ymp

libymp operation controller

For example:

```vala

int main(string[] args){

    var ymp = new ymp_init(args);

    ymp.add_process("install",{"ncurses", "readline"});

    ymp.add_script("install bash glibc perl");

    ymp.run();

    return 0;

}

```

`void Ymp.add_process(string type, string[] args):`

add ymp process using **type** and **args**

* type is operation type (install, remove, list-installed ...)

* args is operation argument (package list, repository list ...)

`void Ymp.clear_process():`

remove all ymp process

`void Ymp.run():`

run ymp process then if succes remove

`void Ymp.add_script(string data):`

add ymp process from ymp script

`string[] argument_process(string[] args):`

Clear options and apply variables from argument

`Ymp ymp_init(string[] args):`

start ymp application.

* args is program arguments

# src/ymp-cli.vala
