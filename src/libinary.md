## class archive()
Load & axtract archive files.

example usage:

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

* Document line must starts with `//DOC:`
