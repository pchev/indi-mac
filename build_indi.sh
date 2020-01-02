#/bin/bash

if [ -z "${ASTRO_ROOT}" ]
then
		echo "no root directory! aborting build script!"
		exit 9
fi

#This should stop the script so that it doesn't run if these paths are blank.
#That way it doesn't try to edit /Applications instead of ${CRAFT_DIR}/Applications for example
	if [ -z  "${CRAFT_DIR}" ] || [ -z  "${DIR}" ]
	then
		echo "directory error! aborting build script!"
		exit 9
	fi

# install prereq
echo Install xcode command line
xcode-select --install
if [ -d "/usr/local/Homebrew" ]
then 
  echo Homebrew already installed
else  
  echo Install Homebrew
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi  
brew upgrade
brew install python
brew install gpsd 

mkdir -p $ASTRO_ROOT

# install craft
if [ -d "${CRAFT_DIR}" ]
then
  echo Craft already installed
else  
  echo Install Craft
  mkdir -p $CRAFT_DIR
  curl https://raw.githubusercontent.com/KDE/craft/master/setup/CraftBootstrap.py -o setup.py 
  python3.7 setup.py --prefix $CRAFT_DIR
fi  

# install INDI craft scripts 
echo Get INDI scripts
cd $ASTRO_ROOT
if [ -d "${DIR}" ]
then
   cd "${DIR}"
   git pull
else   
   git clone https://github.com/rlancaste/kstars-on-osx-craft.git
fi   

# setup craft
echo Setup Craft
cp $DIR/settings/CraftSettings.ini $CRAFT_DIR/etc/
cp $DIR/settings/BlueprintSettings.ini $CRAFT_DIR/etc/
rm -rf $CRAFT_DIR/etc/blueprints/locations/craft-blueprints-kde
cd $CRAFT_DIR/etc/blueprints/locations
git clone https://github.com/rlancaste/craft-blueprints-kde.git

#fix cfitsio
sed -i.bak "s/ftp:\/\/heasarc\.gsfc\.nasa\.gov/https:\/\/heasarc\.gsfc\.nasa\.gov\/FTP/" craft-blueprints-kde/libs/cfitsio/cfitsio.py
# force new version
sed -i.bak "s/ver = '[0-9].[0-9].[0-9]'/ver = '${BUILD_INDI_VERSION}'/" craft-blueprints-kde/libs/indiserver/indiserver.py
sed -i.bak "s/ver = '[0-9].[0-9].[0-9]'/ver = '${BUILD_INDI_VERSION}'/" craft-blueprints-kde/libs/indiserver3rdParty/indiserver3rdParty.py
sed -i.bak "s/ver = '[0-9].[0-9].[0-9]'/ver = '${BUILD_INDI_VERSION}'/" craft-blueprints-kde/libs/indiserver3rdPartyLibraries/indiserver3rdPartyLibraries.py
# fix new repo
sed -i.bak "s/indi.git/indi-3rdparty.git/" craft-blueprints-kde/libs/indiserver3rdParty/indiserver3rdParty.py
sed -i.bak "s/indi.git/indi-3rdparty.git/" craft-blueprints-kde/libs/indiserver3rdPartyLibraries/indiserver3rdPartyLibraries.py

# build indi
echo Build INDI
source $CRAFT_DIR/craft/craftenv.sh
TARGET_VER="default"
# cleanup old library because old link are not replaced by make install 
rm $CRAFT_DIR/lib/libfishcamp*.dylib
rm $CRAFT_DIR/lib/libqsiapi*.dylib
rm $CRAFT_DIR/lib/libapogee*.dylib
rm $CRAFT_DIR/lib/libfli*.dylib
rm $CRAFT_DIR/lib/libtoupcam*.dylib
rm $CRAFT_DIR/lib/libatikcameras2*.dylib
rm $CRAFT_DIR/lib/libqhyccd*.dylib
rm $CRAFT_DIR/lib/libaltaircam*.dylib
rm $CRAFT_DIR/lib/libsbig*.dylib
# build
craft -i --target "${TARGET_VER}" indiserver
if [[ $? != 0 ]]; then exit 1; fi
craft -i --target "${TARGET_VER}" indiserver3rdPartyLibraries
if [[ $? != 0 ]]; then exit 1; fi
craft -i --target "${TARGET_VER}" indiserver3rdParty
if [[ $? != 0 ]]; then exit 1; fi

#This will build gsc
echo "Building GSC"
craft gsc
if [[ $? != 0 ]]; then exit 1; fi

