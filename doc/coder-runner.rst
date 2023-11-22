Code-Runner
===========
Creating a code-runner config
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To create a code-runner config, you can use the following command:

.. code-block:: shell

	ymp code-runner --create build.yaml

This command generates a code-runner config file named build.yaml.

Execute code-runner
^^^^^^^^^^^^^^^^^^^
To execute code-runner with a specific configuration file, use the following command:

.. code-block:: shell

	ymp code-runner build.yaml

Replace build.yaml with the path to your code-runner configuration file.

code-runner configuration file
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Below is an example of a code-runner configuration file (build.yaml):

.. code-block:: yaml

	name: example
	on-fail: fail-job

	steps:
	  - main

	jobs:
	  main:
	    uses: local
	    directory: /tmp/ymp-build
	    image: undefined
	    run:
	      - echo hello world

	  fail-job:
	    uses: local
	    image: undefined
	    directory: /tmp/ymp-build
	    run: |
	      echo "Failed"


Configuration Sections:

* **name:** Specifies the name of the code-runner configuration.

* **on-fail:** Specifies the job that should be executed if any of the previous jobs fail.

* **steps:** Defines the order in which the jobs are executed. In the provided example, there is a single step named "main."

* **jobs:** Contains job definitions. Each job has a name ("main" and "fail-job" in this example), uses a certain source (in this case, "local"), specifies a working directory, defines an image, and provides a script to run.

Job definition:

* **uses**: Specifies the source for the job. It can be a local source, a remote repository, or any other source. In the example, "some-source" and "another-source" are placeholders for the source of the job.

* **directory**: Sets the working directory for the job. Commands within the job will be executed relative to this directory. For example, "/path/to/working/directory" and "/path/to/another/directory" are placeholders for the working directories.

* **image**: Specifies the Docker image to be used for the job. This is optional, and if not provided, the job may run in the host environment. The Docker image can include necessary dependencies for the commands in the job.

* **run**: Contains the actual commands to be executed in the job. It can be a single command or a list of commands. Commands can be specified as a list (using -) or as a multiline string (using |). In the example, "command1," "command2," and "echo 'Running job2'" are placeholders for the actual commands to be executed.



Create plugins
^^^^^^^^^^^^^^
Create new file in ymp source code. under **src/util/code_runner_plugins** directory.

**example.vala** file content:

.. code-block:: java

	public void my_init(string image, string directory){
	    // Initialization logic
	}

	public int my_run(string command){
	    // Run logic
	}

	public void my_clean(){
	    // Clean logic
	}
	public void code_runner_example_init(){
	    my_plugin = new code_runner_plugin();
	    my_plugin.name = "my_plugin";
	    my_plugin.init.connect(my_init);
	    my_plugin.run.connect(my_run);
	    my_plugin.clean.connect(my_clean);
	    add_code_runner_plugin(my_plugin);
	}

**Note:** **code_runner_xxx_init** function automatically called by ymp. **xxx** must same with file name.

Then rebuild ymp.

.. code-block:: shell

	meson setup build
	ninja -C build
	ninja -C build install


