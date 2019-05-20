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
cp $DIR/CraftSettings.ini $CRAFT_DIR/etc/
cp $DIR/BlueprintSettings.ini $CRAFT_DIR/etc/
rm -rf $CRAFT_DIR/etc/blueprints/locations/craft-blueprints-kde
cd $CRAFT_DIR/etc/blueprints/locations
git clone https://github.com/rlancaste/craft-blueprints-kde.git

# build indi
echo Build INDI
source $CRAFT_DIR/craft/craftenv.sh
TARGET_VER="latest"
craft -i --target "${TARGET_VER}" indiserver
craft -i --target "${TARGET_VER}" indiserver3rdPartyLibraries
craft -i --target "${TARGET_VER}" indiserver3rdParty
