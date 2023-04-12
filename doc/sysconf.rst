Writing sysconf file
====================
Sysconf files are package hook mechanism for ymp.
Sysconf files is generally simple shell script but you can prefer any language.

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

