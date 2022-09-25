#!/bin/bash -i
rm -rf build ./test/example/rootfs /tmp/ymp-build|| true
mkdir -p ./test/example/rootfs/etc
cp data/ymp.conf ./test/example/rootfs/etc/ymp.conf
# find src -type f -exec sed -i  "s/ *$//g" {} \;
meson build $@ 
ninja -C build
DESTDIR=output ninja install -C build
cd build
export G_DEBUG=fatal-criticals
export LD_LIBRARY_PATH="$(pwd)":$LD_LIBRARY_PATH
yes | ./ymp-test --allow-oem --ask || true
echo "-------------"
./ymp-cli shell ../test/test.ympsh --allow-oem --destdir=../test/example/rootfs || true
#./ymp-cli build ../test/example/source-package --allow-oem --verbose
if [[ "$DEBUG" != "" ]] ; then
    ./ymp-cli --args ./ymp-cli install ../test/example/source-package/hello_2.10_x86_64.ymp --destdir=../test/example/rootfs --allow-oem --verbose --debug
else
    ./ymp-cli install ../test/example/source-package/hello_2.10_x86_64.ymp --destdir=../test/example/rootfs --allow-oem
fi
