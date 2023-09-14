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

**`** character execute command and replace output with yourself

.. code-block:: shell

    set dist `uname -a`
    echo $dist

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

