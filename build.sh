rm -rf build
meson build $@
ninja -C build
cd build
export G_DEBUG=fatal-criticals
export LD_LIBRARY_PATH="$(pwd)":$LD_LIBRARY_PATH
yes | ./inary-test --ask --no-color || true
