#!/bin/bash
cd "$1"
exec &> mkbin.log
find -type f | while read path ; do
    echo -n "$path : "; file $path
done
