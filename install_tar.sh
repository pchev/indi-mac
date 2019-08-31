#/bin/bash

# this script tar INDI from the target application for deployment elsewhere

#This should stop the script so that it doesn't run if these paths are blank.
#That way it doesn't try to edit /Applications instead of ${CRAFT_DIR}/Applications for example
	if [ -z  "${ASTRO_ROOT}" ] || [ -z  "${TARGET_APP}" ]
	then
		echo "directory error! aborting tar script!"
		exit 9
	fi

# cd in target app
cd ${TARGET_APP}
if [[ $? != 0 ]]; then exit 1; fi
# tar indi
tar cvzf indimac.tgz Contents
if [[ $? != 0 ]]; then exit 1; fi
# move to root
mv indimac.tgz ${ASTRO_ROOT}/
if [[ $? != 0 ]]; then exit 1; fi

