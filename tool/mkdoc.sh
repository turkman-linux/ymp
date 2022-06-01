#!/bin/bash
while read file ; do
    echo "# $file"
    cat $file | grep "//DOC:" | sed "s|.*//DOC: ||g;s|;$|\\n|g"
done