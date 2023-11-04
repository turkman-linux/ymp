#!/bin/bash
set -e
if which nm && which patchelf ; then
    : Remove symver
else
    exit 0
fi
for file in $@ ; do
    if [ ! -f $file ] ; then
        continue;
    fi
    nm --dynamic --undefined-only --with-symbol-versions $file | \
        grep GLIBC | tr -s " " | cut -f3 -d" " | cut -f1 -d"@" | while read sym; do
        patchelf --clear-symbol-version $sym $file
    done
done
