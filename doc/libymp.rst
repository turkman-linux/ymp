Create application with libymp
==============================
libymp is part of ymp. We can call ymp operation from libymp.

Example hello world program like this:

.. code-block:: C

	#include <ymp.h>
	int main(int argc, char* argsv[]){
	    Ymp *y = ymp_init(argv, argc);
	    ymp_add_script(y,"echo Hello World");
	    return ymp_run(y);
	}

You can compile this application with gcc like this:

.. code-block:: shell

	# single command
	gcc main.c -o main `pkg-config --libs --cflags ymp`
	# alternative way
	gcc -c main.c `pkg-config --cflags ymp`
	gcc -o main main.o `pkg-config --libs ymp`

**Ymp** struct is ymp operation object. You must create with **ymp_init**. **ymp_add_script** function add ymp shell script into ymp object. **ymp_run** call ymp operations and return exit status.

For all ymp function please see **/usr/include/ymp.h** header.
