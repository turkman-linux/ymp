build: clean
	meson setup build --prefix=/usr -Ddoc=true -Ddebug=true -Dshared=true -Dscripts=true
	ninja -C build

test: test-clean
	meson setup build/_test -Dtest=true -Dtools=false -Dscripts=false -Ddebug=true
	ln -s ../test build/test
	ninja -C build/_test
	cd build/_test ; env LD_LIBRARY_PATH="$$(pwd)"/build G_DEBUG=fatal-criticals yes | timeout 30 ./ymp-test --allow-oem --ask

install:
	DESTDIR=$(DESTDIR) ninja -C build install

test-clean:
	rm -rf build/_test ctx.vala


clean:
	rm -rf build ctx.vala
