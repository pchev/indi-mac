#!/bin/bash

# Get target app location
source build_env

# Set required environment 
export INDIPREFIX="${TARGET_APP}"
echo "Using INDI in "$INDIPREFIX
export PATH="${INDIPREFIX}/Contents/Resources/DriverSupport:${INDIPREFIX}/Contents/MacOS/indi:$PATH"
export IOLIBS="${INDIPREFIX}/Contents/Resources/DriverSupport/gphoto/IOLIBS"
export CAMLIBS="${INDIPREFIX}/Contents/Resources/DriverSupport/gphoto/CAMLIBS"

# Run the server
echo Starting server. use Crtl+C to exit
indiserver -v indi_simulator_ccd indi_simulator_telescope

