Ymp Shell
=========
You can create new ymp shell with **ymp shell** command or **ympsh** command. You can run ymp operations into shell.

.. code-block:: shell

	ymp shell
	-> Ymp >> install git

Commends
^^^^^^^^
You can use **#** symbol or **:** operdation (dummy)

.. code-block:: shell

	# hello world
	: Hello world

Escape & exclusive characters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**$** character used for variables.

.. code-block:: shell

	set num 13
	echo $num
	# It is not equal to test13
	echo test$num
	# It is not equal 13test
	echo $numtest

**\\** character ignore next characters functions

.. code-block:: shell

	set msg Hello\ World
	echo $msg

**"** and **'** characters define string

.. code-block:: shell

	set msg "Hello World"
	echo $msg

**`** character execute command and replace output with yourself (for preprocesing)

.. code-block:: shell

	set dist `uname -a`
	echo $dist

Expressions
^^^^^^^^^^^
**$(xxxx)** expression execute command and replace output with yourself.

.. code-block:: shell

	# get current uid
	set uid "$(id -u)"
	print $uid

**--** stop expressioning

.. code-block:: shell

	# print stuff
	print -- $hello $world

**${xxx}** expression used for variables. 

.. code-block:: shell

	# expr command from shell
	set num 2
	print "$(expr ${num} + 2)"

Conditions
^^^^^^^^^^
**If** segment used for conditions. If segment must starts with **if** and must ends with **endif**

.. code-block:: shell

	read var
	if eq 12 $var
		echo equal to 12
	endif

The keyword **and** compares left and right. Return true if both return true.

.. code-block:: shell

	if eq 1 1 and eq 2 2
		echo equal
	endif

The keyword **or** compares left and right. Return true if anyone returns true.

.. code-block:: shell

	if eq 1 1 or eq 2 0
		echo equal
	endif

The keyword **not** takes the opposite

.. code-block:: shell

	if not eq 2 0
		echo not equal
	endif


Labels and goto
^^^^^^^^^^^^^^^
You can define label and use **goto** word like this

.. code-block:: shell

	label test
	read var
	if eq $var 0
		exit
	endif
	echo $var
	goto test

This program can simulate while loop

ret keyword
^^^^^^^^^^^^
If you use **goto** current code point saved. If you use **ret** saved point restored.

.. code-block:: shell

	if eq 0 1
	  label hello
		echo hello
		ret
	endif
	if eq 0 1
	  label word
		echo world
		ret
	endif
	goto hello
	goto world

This program can simulate functions.

