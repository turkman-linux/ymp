Building a ympbuild file
========================
You must run `ymp build <directory>` command without root. If you want to sandbox environment, you should run command like this:

.. code-block:: shell

	$ fdir=./repo/stuff-package/
	$ ymp build "$fdir" --sandbox --shared="$fdir"

Basics of ympbuild
==================
**ymp** package manager uses **ympbuild** file. **ympbuild** file is simple bash script and call by ymp. You should define variables and functions. Minimal example ympbuild look like this:

.. code-blockj:: shell

	#!/usr/bin/env bash
	name=example
	version=1.0
	release=1
	url='https://example.org'
	description='example package'
	email='your-name@example.org'
	maintainer='linuxuser'
	depends=(foo bar)
	source=("https://example.org/source.zip"
	"some-stuff.patch"
	)
	md5sums=('bb91a17fd6c9032c26d0b2b78b50aff5'
	'SKIP'
	)
	license=('GplV3')
	prepare(){
    	   ...
	}
	setup(){
    	   ...
	}
	build(){
	    ...
	}
	package(){
	   ...
	}

You can create ympbuild from template. Please see `ymp template --help`.

variables
^^^^^^^^^
* **name** variable is package name. Must be string.
* **version** variable is package version. Could be string or integer.
* **release** variable is package release number. ymp compares this number to select upgraded packages.
* **url** variable is package upstream url. Ymp doesn't use this variable.
* **description** variable is package description. Must be string.
* **email** variable is package maintainer email adress. Must be string.
* **maintainer** variable is package maintairen nickname (or real name). Must be string.

arrays
^^^^^^
* **depends** array is base runtime dependencies. Could be empty. 
* **source** array is package source list. ymp downloads or copies this sources into build directory.
* **md5sums** array is package source hash list. ymp checks sources with this hashes.
* **uses** and **uses_extra** arrays are use flag definitions.
* **license** array is package licenses list.

functions
^^^^^^^^^
* **prepare** function is source preparation stage. You can patch or modify source in this stage.
* **setup** function is source configuration stage. You can configure source in this stage.
* **build** function is compile stage. You can compile source.
* **package** function is installation stage. You can install source into packaging directory.

ympbuild directories
====================
Every build has own build directory in **/tmp/ymp-build/<build-id>**. **build-id** is actually md5sum of **ympbuild** file so if you modify ympbuild, build-id will changed. Build directory defined as **HOME** environmental variable. You can simply use `cd` instead of `cd /tmp/ymp-build/<build-id>`.

Source archive extracted into build directory and ympbuild called from build directory. Packaging directory is **/tmp/ymp-build/<build-id>/output**. If you insert a file into this directory, ymp will add this file into package. also packaging directory defined as **installdir** and **DESTDIR** environmental variable. You can use simply `make install` instead of `make install DESTDIR=${installdir}`. 

Note: Generally **/tmp** directory is **tmpfs** so has limited space. If you want more space you must remove **/tmp/ymp-build** and symlink from other location. (location must have read, write and executable permission)

Use flags
=========
You can define **uses** and **uses_extra** array for definition use flags. Use flags can be used to customize the build. For example:

.. code-block:: shell

	...
	uses=(foo bar)
	uses_extra=(bazz)
	foo_depends=(foo bazz)
	...
	setup(){
	    ../configure --prefix=/usr \
	    $(use_opt foo --with-foo --without-foo)
	}
	...
	package(){
	    ...
	    if use bar ; then
	        install stuff ${DESTDIR}/bin/stuff
	    fi
	}

**use_opt** is option selector. Usage is `use_opt <use_flag> <if_enabled> <if_disabled>`. 
**use** is option checker. If use flag selected return true.

You can pass use flags with **--use="foo bar"** argument or **USE="foo bar"** environmental variable. For example:

.. code-block:: shell

	# --use parameter method.
	$ ymp build --use="foo bar" ./repo/foo-package/
	# envitormental variable method.
	$ USE="foo bar" ymp build  ./repo/foo-package/
	# or you can define use flags into /etc/ymp.conf file

If you add **all** into use flag list. Ymp enable all use flags except uses_extra flags. If you add **extra**, ymp enable all extra use flags.

Note: If you define **xxx** into use flag list, **xxx_depends** array items are automatically added into **depends** array.

Note: Use flags is not usable for binary packages.


