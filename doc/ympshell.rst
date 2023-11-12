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

**\\** character ignore next characters functions

.. code-block:: shell

    set msg Hello\ World
    echo $msg

**"** character define string

.. code-block:: shell

    set msg "Hello World"
    echo $msg

**`** character execute command and replace output with yourself (preprocessor)

.. code-block:: shell

    set dist `uname -a`
    echo $dist

Expressions
^^^^^^^^^^^
**$(xxxx)** expression execute command and replace output with yourself. For example:

.. code-block:: shell

	# get current uid
	set uid "$(id -u)"
	print $uid

**--** stop argument processing

.. code-block:: shell

	# print stuff
	print -- $hello $world

Conditions
^^^^^^^^^^
**If** segment used for conditions. If segment must starts with **if** and must ends with **endif**

.. code-block:: shell

    read var
    if eq 12 $var
        echo equal to 12
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

ret keyworld
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

