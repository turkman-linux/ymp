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

Using libymp with vala
^^^^^^^^^^^^^^^^^^^^^^

You can use ymp with vala using vapi. For example:

.. code-block:: java

	int main(string[] argv){
	    Ymp y = ymp_init(argv);
	    string[] args = {"Hello","World"};
	    y.add_process("echo",args);
	    y.run();
	    return 0;
	}

You can build code with this command:

.. code-block:: shell

	valac main.vala --pkg ymp

An alternative method you can use C based library on vala.

.. code-block:: java

	extern void ymp_init(string[] args);
	extern int echo_main(string[] args);
	int main(string[] argv){
	    ymp_init(argv);
	    string[] args={"Hello"};
	    echo_main(args);
	    return 0;}
	}

And compile program with this command.

.. code-block:: shell

	valac main.vala -X -lymp

**Note:** This method is a bad idea but working :)

Usefull library parts of libymp
===============================
libymp provide some usefull functions.

The array library of libymp
^^^^^^^^^^^^^^^^^^^^^^^^^^^
An example array library usage in here:

.. code-block:: shell

	#include <ymp.h>
	#include <glib/gprintf.h>

	int main(){
		array *a = array_new();
	    array_add(a,"hello");
	    array_add(a,"world");
	    gint len=0;
	    for(int i=0;i<array_length(a);i++){
	        g_printf("%s ",array_get(a,&len)[i]);
	        g_printf("%d\n",len);
	    }
	    return 0;
	}

**Note:** Array library uses glib types. You can use standard types but it is not recommended.

