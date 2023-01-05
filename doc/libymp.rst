Create application with libymp
==============================
libymp is part of ymp. We can call ymp operation from libymp.

How to compile
^^^^^^^^^^^^^^
You can compile application with gcc like this:

.. code-block:: shell

	# single command
	gcc main.c -o main `pkg-config --libs --cflags ymp`
	# alternative way
	gcc -c main.c `pkg-config --cflags ymp`
	gcc -o main main.o `pkg-config --libs ymp`

Simple application
^^^^^^^^^^^^^^^^^^
You can run libymp functions like this:

.. code-block:: C

	#include <ymp.h>
	int main(int argc, char* argv[]){
	    ymp_init(argv, argc);
	    char* args[] = {"Hello", "World"};
	    echo_main(args,2);
	}

**ymp_init** create ymp operation manager object to run ymp functions. all libymp operations must require **char* args[]** and **int argc** arguments. You should send main function arguments to **ymp_init** function.

Ymp operation manager
^^^^^^^^^^^^^^^^^^^^^
Example hello world program with ymp operation manager like this:

.. code-block:: C

	#include <ymp.h>
	int main(int argc, char* argv[]){
	    Ymp *y = ymp_init(argv, argc);
	    // script add
	    ymp_add_script(y,"echo Hello World");
	    // process add
	    char* args[] = {"Hello", "World"};
	    ymp_add_process(y, "echo", args, 2);
	    return ymp_run(y);
	}

**Ymp** struct is ymp operation object. You must create with **ymp_init**.
**ymp_add_script** function add ymp shell script into ymp object.
**ymp_add_process** function add ymp process into ymp object.
**ymp_run** call ymp operations and return exit status.

For all ymp function please see **/usr/include/ymp.h** header.


