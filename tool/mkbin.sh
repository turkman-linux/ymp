#!/bin/bash
cd "$1"
find -type f | while read path ; do
    if file $path | grep "ELF" &>/dev/null; then
        objcopy -R ".comment" "$path" || true
        objcopy -R ".gnu.version" "$path" || true
    fi
done
