#!/bin/bash -i
rm -rf build ./test/example/rootfs /tmp/inary-build|| true
mkdir -p ./test/example/rootfs/etc
cp data/inary.conf ./test/example/rootfs/etc/inary.conf
# find src -type f -exec sed -i  "s/ *$//g" {} \;
meson build $@ 
ninja -C build
DESTDIR=output ninja install -C build
cd build
export G_DEBUG=fatal-criticals
export LD_LIBRARY_PATH="$(pwd)":$LD_LIBRARY_PATH
yes | ./inary-test --allow-oem --ask || true
echo "-------------"
./inarysh ../test/test.inarysh --allow-oem --destdir=../test/example/rootfs || true
#./inary-cli build ../test/example/source-package --allow-oem --verbose
./inary-cli install ../test/example/source-package/hello_2.10_x86_64.inary --destdir=../test/example/rootfs --allow-oem
