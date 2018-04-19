# dev-board-examples

Development Board Firmware/Software Examples

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

# Clone the GIT repository

```
$ git clone --recursive git@github.com:slaclab/dev-board-examples
```

# How to build the firmware 

1) Setup Xilinx licensing

> If you are on the SLAC network, here's how to setup the Xilinx licensing

>> In C-Shell: 
```
$ source dev-board-examples/firmware/setup_env_slac.csh
```

>> In Bash:    
```
$ source dev-board-examples/firmware/setup_env_slac.sh
```

2) Go to the target directory (that you want to build) and make the firmware:

> Example of building the Ac701GigE firmware example target
```
$ cd dev-board-examples/firmware/targets/XilinxKCU105DevBoard/Ac701GigE
$ make
```

3) Optional: Review the results in GUI mode
```
$ make gui
```

# How to build/run the software 

1) Install 'rogue' software on your platform

> Build instrustions can be found here:

>> https://github.com/slaclab/rogue/blob/master/Readme_build.txt

> If you are on the SLAC network, there in a network install of rogue on AFS:
 ```
/afs/slac/g/reseng/rogue/master/
```

2) Go to your git clone's rogue software directory
```
$ cd dev-board-examples/software/rogue
```

3) Setup your environment (example below assumes access to SLAC AFS):
```
$ source  setup_template.csh
```

4) Launch the PyQT QUI
```
$ python3 scripts/DevBoardGui.py 
```

