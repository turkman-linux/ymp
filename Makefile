build: clean
	meson build --prefix=/usr
	ninja -C build
install:
	DESTDIR=$(DESTDIR) ninja -C build install

clean:
	rm -rf build
