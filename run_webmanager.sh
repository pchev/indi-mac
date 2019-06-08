#!/bin/bash

# To install INDI webmanager on the Mac:
# It work with Apple Python 2.7, no need to install other Python
# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
# sudo -H python get-pip.py
# sudo -H pip install indiweb

# The application INDI is installed to
export TARGET_APP=~/src/indi-mac/testapp/test.app
#export TARGET_APP=/Applications/IndiStarter.app
#export TARGET_APP=/Applications/kstars.app

# Set required environment 
export INDIPREFIX="${TARGET_APP}"
echo "Using INDI in "$INDIPREFIX
export PATH="${INDIPREFIX}/Contents/Resources/DriverSupport:${INDIPREFIX}/Contents/MacOS/indi:$PATH"
export IOLIBS="${INDIPREFIX}/Contents/Resources/DriverSupport/gphoto/IOLIBS"
export CAMLIBS="${INDIPREFIX}/Contents/Resources/DriverSupport/gphoto/CAMLIBS"

# the GSC catalog for the simulator
export GSCDAT=~/Documents/gsc

# Run the server
echo Starting INDI webmanager. use Crtl+C to exit
indi-web -v --xmldir $INDIPREFIX/Contents/Resources/DriverSupport

