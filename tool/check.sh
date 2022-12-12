#!/bin/bash
set -ex
touch "$1"/ymp.h
touch "$1"/ymp.vapi
touch "$1"/ymp-cli
touch "$1"/ymp-shell
touch "$1"/ymp-cli-static
touch "$1"/ymp-shell-static
touch "$1"/libymp.so
touch "$1"/libymp-static.a
echo -n | gcc -c -x c - -o "$1"/obj.o
for sec in $(readelf -WS "$1"/obj.o | grep "\[.*\] \."| cut -f 2 -d "]" | tr -s " " | cut -f2 -d" ") ; do
    objcopy -R$sec "$1"/obj.o &>/dev/null || true
done
