# indi-mac
# Scripts to add INDI to any Mac application

This scripts allow to compile INDI with Craft and add it to any client application bundle.

The first step is to edit the file **build_env** to setup the directories to use, the INDI version to compile and the target application.
Open a terminal and source this file every time before to run another script.

On this terminal run the script **build_indi.sh** to install Craft and the other prerequisites, then compile the INDI server and drivers.
This step is only to be repeated when you want a new version of INDI.

To add INDI to the application be sure **build_env** contain the right application path and name, then source it. Then run the script **install_indi.sh** to copy the required binaries in the application bundle.

The last step is to run the script **install_libraries.sh** to copy the required libraries and fix the rpath.

## Typical use:

- mkdir ~/src 
- cd ~/src
- git clone https://github.com/pchev/indi-mac.git
- cd indi-mac
- vi build_env
- source build_env
- ./build_indi.sh > build_indi.log 2>&1
- ./install_indi.sh > install_indi.log 2>&1
- ./install_libraries.sh > install_libraries.log 2>&1
- cd testapp/test.app/Contents/MacOS/indi/
- ./indiserver ./indi_simulator_telescope

## Source scripts:

This scripts are based on the one written for Kstars by Rob Lancaster (rlancaste). 

https://github.com/rlancaste/kstars-on-osx-craft

