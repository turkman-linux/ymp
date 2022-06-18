#!/bin/bash -i
rm -rf build || true
# find src -type f -exec sed -i  "s/ *$//g" {} \;
meson build $@ -Ddebug=false -Dtools=true
ninja -C build
cd build
export G_DEBUG=fatal-criticals
export LD_LIBRARY_PATH="$(pwd)":$LD_LIBRARY_PATH
yes | ./inary-test --allow-oem --ask || true
echo "-------------"
./inarysh ../test/test.inarysh --allow-oem --destdir=../test/example/rootfs || true
./inary-cli build ../test/example/source-package --allow-oem --verbose --no-download --no-build