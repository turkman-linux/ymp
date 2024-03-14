SHELL=/bin/bash
build: clean
	meson setup build --prefix=/usr -Ddoc=true -Ddebug=true -Dscripts=true -Dlibbrotli=false
	ninja -C build
	bash scripts/remove-symver build/libymp.so build/ymp-cli build/ymp-shell

minimal:
	meson setup build --prefix=/usr -Ddoc=false -Ddebug=false -Dscripts=false -Dlibbrotli=false -Dlibcurl=false -Dlibarchive=false
	ninja -C build
	bash scripts/remove-symver build/libymp.so build/ymp-cli build/ymp-shell


release: clean
	meson setup build --prefix=/usr -Ddoc=true -Ddebug=false -Dscripts=true -Dlibbrotli=false
	ninja -C build

static: clean
	meson setup build --prefix=/usr -Ddoc=true -Ddebug=true -Dstatic=true -Dscripts=true -Dlibbrotli=false
	ninja -C build

test: test-clean
	meson setup build/_test -Dtest=true -Dtools=false -Dscripts=false -Ddebug=true
	ln -s ../test build/test
	ninja -C build/_test
	cd build/_test ; env LD_LIBRARY_PATH="$$(pwd)"/build G_DEBUG=fatal-criticals yes | timeout 30 ./ymp-test --allow-oem --ask

install:
	DESTDIR=$(DESTDIR) ninja -C build install

test-clean:
	rm -rf build/_test ctx.vala build/test .generated


clean:
	rm -rf build ctx.vala po/*.mo obj-*-linux-gnu .generated

pot:
	xgettext -o po/ymp.pot --from-code="utf-8" `find src -type f -iname "*.vala"` `find src -type f -iname "*.c"` 2>/dev/null
	for file in `ls po/*.po`; do \
	        msgmerge $$file po/ymp.pot -o $$file.new ; \
	    echo POT: $$file; \
	    rm -f $$file ; \
	    mv $$file.new $$file ; \
	done
	sed -f data/fix-turkish.sed -i po/tr.po

fix:
	find src -type f -exec sed -i "s/^ *$$//g;s/ *$$//g" {} \;
