Writing sysconf file
====================
Sysconf files are package hook mechanism for ymp.
Sysconf files is generally simple shell script but you can prefer any language.
All sysconfig files located at **/etc/sysconf.d**. You can trigger manually with **ymp sysconf** command.

Example sysconf script here:

.. code-block:: shell

	current=$(date +%s -r /usr/share/glib-2.0/schemas/)
	last=$(cat /var/lib/ymp/sysconf/glib/update.date)
	if [ "$current" != "$last" ] ; then
	    glib-compile-schemas /usr/share/glib-2.0/schemas/
	    date +%s -r /usr/share/glib-2.0/schemas/ > /var/lib/ymp/sysconf/glib/update.date
	fi

* /var/lib/ymp/sysconf/<hookname> directory created by ymp.
* Sysconf directories removed after package uninstallation.
* You can check directory change time and process hook.

Ymp forward current operation with **OPERATION** environment variable hovewer remove all other environment variables.

.. code-block:: shell
	
	OPERATION=postinst
	SHLVL=2
	TERM=linux
	PATH=/usr/bin:/bin:/usr/sbin:/sbin
	PWD=/

* **prerm** called before remove operation
* **postrm** called after remove operation
* **preinst** called after install operation
* **postinst** called after install operation
* other operation names same as operation name

Note: You can not use sysconf **preinst** and **postrm** from target package.
Because package sysconf files are part of package.

