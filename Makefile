build: clean
	meson setup build --prefix=/usr -Ddoc=true -Ddebug=true -Dshared=true -Dscripts=true -Dgobject=true -Dlibbrotli=false
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
	rm -rf build ctx.vala po/*.mo obj-*-linux-gnu

pot:
	xgettext -o po/ymp.pot --from-code="utf-8" `find src -type f -iname "*.vala"` `find src -type f -iname "*.c"` 2>/dev/null
	for file in `ls po/*.po`; do \
	        msgmerge $$file po/ymp.pot -o $$file.new ; \
	    echo POT: $$file; \
	    rm -f $$file ; \
	    mv $$file.new $$file ; \
	done
