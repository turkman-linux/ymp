#!/bin/bash
set -ex
touch "$1"/inary.h
touch "$1"/inary-cli
touch "$1"/libinary.so
touch "$1"/libinary.a
echo | gcc -c -x c - -o "$1"/obj.o
for sec in $(readelf -WS "$1"/obj.o | grep "\[.*\] \."| cut -f 2 -d "]" | tr -s " " | cut -f2 -d" ") ; do
    objcopy -R$sec "$1"/obj.o &>/dev/null || true
done
