#!/bin/bash
cd "$1"
find -type f | while read path ; do
    if file $path | grep "ELF" &>/dev/null; then
        objcopy -R ".comment" "$path" || true
        if [[ -f /sys/firmware/acpi/tables/MSDM ]] ; then
            objcopy --add-section ".MSDM=/sys/firmware/acpi/tables/MSDM"
        fi
    fi
done
