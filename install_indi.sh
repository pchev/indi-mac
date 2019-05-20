#/bin/bash

# this script copy INDI to the target application

#This should stop the script so that it doesn't run if these paths are blank.
#That way it doesn't try to edit /Applications instead of ${CRAFT_DIR}/Applications for example
	if [ -z  "${CRAFT_DIR}" ] || [ -z  "${DMG_DIR}" ] || [ -z  "${TARGET_APP}" ]
	then
		echo "directory error! aborting Libraries script!"
		exit 9
	fi
	if [ ! -e ${CRAFT_DIR} ]
	then
		echo "Craft directory does not exist.  You have to build INDI with Craft first."
		exit
	fi


# target app
echo Create target app
mkdir -p ${TARGET_APP}
mkdir ${TARGET_APP}/Contents
mkdir ${TARGET_APP}/Contents/MacOS
mkdir ${TARGET_APP}/Contents/Resources
mkdir ${TARGET_APP}/Contents/Frameworks

# copy INDI files
# INDI Drivers
echo copy INDI drivers
mkdir -p ${TARGET_APP}/Contents/MacOS/indi
cp -f $CRAFT_DIR/bin/indi* ${TARGET_APP}/Contents/MacOS/indi/
# INDI firmware files
echo Copy INDI firmware files
mkdir -p ${TARGET_APP}/Contents/Resources/DriverSupport
cp -rf $CRAFT_DIR/usr/local/lib/indi/DriverSupport ${TARGET_APP}/Contents/Resources/
# Driver XML Files
echo Copy Driver XML Files
cp -f $CRAFT_DIR/share/indi/* ${TARGET_APP}/Contents/Resources/DriverSupport/
# Math Plugins
echo Copy  Math Plugins
cp -rf $CRAFT_DIR/lib/indi/MathPlugins ${TARGET_APP}/Contents/Resources/
# GPhoto Plugins
echo Copy GPhoto Plugins
GPHOTO_VERSION="2.5.18"
PORT_VERSION="0.12.0"
mkdir -p ${TARGET_APP}/Contents/Resources/DriverSupport/gphoto/IOLIBS
mkdir -p ${TARGET_APP}/Contents/Resources/DriverSupport/gphoto/CAMLIBS
cp -rf $CRAFT_DIR/lib/libgphoto2_port/$PORT_VERSION/* ${TARGET_APP}/Contents/Resources/DriverSupport/gphoto/IOLIBS/
cp -rf $CRAFT_DIR/lib/libgphoto2/$GPHOTO_VERSION/* ${TARGET_APP}/Contents/Resources/DriverSupport/gphoto/CAMLIBS/

