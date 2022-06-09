# src/ccode.vala
## Inary C source adaptations

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

# src/color.vala
## Colors

Available colors

black, red, green, yellow, blue, magenta, cyan, white

`string colorize(string message, int color):`

Change string color if no_color is false.

Example usage:

```vala

var msg = colorize("Hello",red);

var msg2 = colorize("world",blue);

stdout.printf(msg+" "+msg2);

```

# src/data/dependency.vala
## Dependency analysis

resolve dependencies

`string[] resolve_dependencies(string[] names):`

return package name list with required dependencies

# src/data/package.vala
## class package

inary package struct & functions

Example usage:

```vala

var pkg = new package();

pkg.load_from_archive("/tmp/bash-5.0-x86_64.inary");

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

`void package.load(string metadata):`

Read package information from metadata file

`void package.load_from_data(string data):`

Read package information from string data

`void package.load_from_archive(string path):`

Read package information from inary file

`string[] package.list_files():`

return inary package files list

`string[] package.gets(string name):`

Get package array value

`string package.get(string name):`

Get package value

`void package.extract():`

extract package to quarantine directory

quarantine directory is **get_storage()+"/quarantine"**;

Example inary archive format:

```yaml

package.inary

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

`bool package.is_installed():`

return true if package is installed

## Miscellaneous package functions

package functions outside package class

`string[] list_installed_packages():`

return installed package names array

`package get_installed_packege(string name):`

get package object from installed package name

`bool is_installed_package():`

return true if package installed

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

`package repository.get_package(string name):`

get package object from repository by package name

`string[] repository.list_packages():`

get all available package names from repository

## Miscellaneous repository functions

repository functions outside repository class

`repository[] get_repos():`

get all repositories as array

`package get_package_from_repository(string name):`

get package object from all repositories

# src/inary.vala
## class Inary

libinary operation controller

For example:

```vala

int main(string[] args){

    var inary = new inary_init(args);

    inary.add_process("install",{"ncurses", "readline"});

    inary.add_script("install bash glibc perl");

    inary.run();

    return 0;

}

```

`void Inary.add_process(string type, string[] args):`

add inary process using **type** and **args**

* type is operation type (install, remove, list-installed ...)

* args is operation argument (package list, repository list ...)

`void Inary.clear_process():`

remove all inary process

`void Inary.run():`

run inary process then if succes remove

`void Inary.add_script(string data):`

add inary process from inary script

`string[] argument_process(string[] args):`

Clear options and apply variables from argument

`Inary inary_init(string[] args):`

start inary application.

* args is program arguments

# src/operations/clear.vala
# src/operations/dummy.vala
# src/operations/echo.vala
# src/operations/exec.vala
# src/operations/exit.vala
# src/operations/install.vala
# src/operations/list.vala
# src/operations/setget.vala
# src/settings.vala
## Settings functions

inary configuration functions

`void set_destdir(string rootfs):`

change distdir

`string get_storage():`

get inary storage directory. (default: /var/lib/inary)

`void set_config(string path):`

change inary config file (default /etc/inary.conf)

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

`string[] archive.list_files():`

Get archive file list

`void archive.set_target(string path):`

Change target directory for extract

`void archive.extract(string path):`

Extract **path** file to target directory

`string archive.readfile(string path):`

Read **path** file to target directory

`void archive.extract_all()`

Extract all files to target

# src/util/command.vala
## Command functions

This functions call shell commands

Example usage

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

`int run_args(string[] args):`

ruh command from argument array

`int run_args(string[] args):`

ruh command from argument array

# src/util/fetcher.vala
`void set_fetcher_progress(fetcher_process proc):`

set fetcher progressbar hanndler.

For example:

```vala

public void progress_bar(int current, int total, string filename){

   ...

}

set_fetcher_progress(progress_bar);

```

`bool fetch(string url, string path):`

download file content and write to file

`bool fetch_string(string url, string path):`

download file content and return as string

# src/util/file.vala
## File functions

File & Directory functions

`string readfile_raw (string path):`

Read file from **path** and return content

`string readfile_raw2 (string path):`

Read file from **path** and return content

`string readfile_byte(string path, int size):`

read **n** byte from file

`long get_filesize(string path):`

calculate file size

`string readfile(string path):`

read file from **path** and remove commends

`void writefile(string path, string ctx):`

write **ctx** data to **path** file

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

`void move_file(stirg src, string desc):`

move **src** file to **desc**

`string[] listdir(string path):`

list directory content and result as array

`bool iself(string path):`

return true if file is elf binary

`bool is64bit(string path):`

return true if file is elf binary

`bool isfile(string path):`

Check **path** is file

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

# src/util/iniparser.vala
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

ini.load("/etc/inary.conf");

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

`void nostdin():`

close stdin. Ignore input. This function may broke application.

# src/util/logger.vala
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

`void info(string message):`

write additional info messages.

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

# src/util/value.vala
## Variable functions

set or get inary global variable

Example usage:

```vala

set_value("CFLAGS","-O3");

var jobs = get_value("jobs");

if(get_bool("debug")){

    stderr.printf("Debug mode enabled");

}

```

`void set_value(string name, string value):`

add a global inary variable as string

`string get_value(string name):`

get a inary global variable as string

big names are read only and only defined by inary

`bool get_bool(string name):`

get a inary global variable as bool

`void set_bool(string name, bool value):`

add a global inary variable as bool

`string[] list_values():`

return array of all inary global value names

`void set_env(string variable, string value):`

add environmental variable

`string get_env(string variable):`

get a enviranmental variable

`void clear_env():`

remove all environmental variable except **PATH**

# src/util/yamlparser.vala
## Yaml parser

yaml file parser library for inary

Example usage:

```vala

var yaml = new yamlfile();

yaml.load("/var/lib/inary/metadata/bash.yaml");

var pkgarea = yaml.get("inary.package");

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

