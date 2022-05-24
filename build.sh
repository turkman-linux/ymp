rm -rf build
meson build $@
ninja -C build
LD_LIBRARY_PATH="$(pwd)/build":$LD_LIBRARY_PATH build/inary-test
