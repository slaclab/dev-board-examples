# dev-board-examples

Development Board Firmware/Software Examples

<!--- ########################################################################################### -->

# Before you clone the GIT repository

1) Create a github account:
> https://github.com/

2) On the Linux machine that you will clone the github from, generate a SSH key (if not already done)
> https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

3) Add a new SSH key to your GitHub account
> https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

4) Setup for large filesystems on github

```
$ git lfs install
```

5) Verify that you have git version 2.13.0 (or later) installed 

```
$ git version
git version 2.13.0
```

6) Verify that you have git-lfs version 2.1.1 (or later) installed 

```
$ git-lfs version
git-lfs/2.1.1
```

<!--- ########################################################################################### -->

# Clone the GIT repository

```
$ git clone --recursive git@github.com:slaclab/dev-board-examples
```

<!--- ########################################################################################### -->

# How to build the firmware 

1) Setup Xilinx licensing

> If you are on the SLAC network, here's how to setup the Xilinx licensing
  
```
$ source dev-board-examples/firmware/setup_env_slac.sh
```

> Else you will need to install Vivado and install the Xilinx Licensing

2) Go to the firmware's target directory:

> Example of building the KC705 10 GbE firmware example target:

```
$ cd dev-board-examples/firmware/targets/XilinxKC705DevBoard/Kc705TenGigE
```

3) Optional: Review the results in GUI mode

```
$ make gui
```


3) Build the firmware

```
$ make
```

4) Optional: Open up the project in GUI mode to view the firmware build results

```
$ make gui
```

<!--- ########################################################################################### -->

# How to install the Rogue With Anaconda

> https://slaclab.github.io/rogue/installing/anaconda.html

<!--- ########################################################################################### -->

# How to run the Software Development GUI

```
# Go to software directory
$ cd dev-board-examples/software/rogue

# Activate Rogue conda Environment 
$ source /path/to/my/anaconda3/etc/profile.d/conda.sh

# Setup the Python Environment
$ source setup_env.sh

# Launch the GUI
$ python scripts/DevBoardGui.py
```

<!--- ########################################################################################### -->
