rm -rf build
meson build $@
ninja -C build
cd build
LD_LIBRARY_PATH="$(pwd)":$LD_LIBRARY_PATH ./inary-test --ask --no-color || true
