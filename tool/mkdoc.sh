#!/bin/bash
cat | grep -v "src/tools/" | \
while read file ; do
    echo "# $file"
    cat $file | grep "//DOC:" | sed "s|.*//DOC: ||g;s/$/\n/g"
done
