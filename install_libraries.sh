#/bin/bash

# This script has three goals:
# 1) It makes sure the target folder and application is set up.
# 2) identify programs that use libraries outside of the package (that meet certain criteria)
# 3) copy those libraries to the blah/Frameworks dir
# 4) Update those programs to know where to look for said libraries

#This adds a file to the list so it can be copied to Frameworks
	function addFileToCopy
	{
		for e in "${FILES_TO_COPY[@]}"
		do 
			if [ "$e" == "$1" ]
			then
				return 0
			fi
		done
	
		FILES_TO_COPY+=($1)
	}

#This Function processes a given file using otool to see what files it is using
#Then it uses install_name_tool to change that target to be a file in Frameworks
#Finally, it adds the file that it changed to the list of files to copy there.
	function processTarget
	{
		target=$1
		
		#This hard coded rpath needs to be removed from any files that have it for packaged apps because later there could be rpath conflicts
		#if the program is run on a computer with the same paths as the build computer
		install_name_tool -delete_rpath ${CRAFT_DIR}/lib $file
        	
		entries=$(otool -L $target | sed '1d' | awk '{print $1}' | egrep -v "$IGNORED_OTOOL_OUTPUT")
		echo "Processing $target"
	
		relativeRoot="${TARGET_APP}/Contents"
	
		pathDiff=${target#${relativeRoot}*}

		#This is a Framework file
		if [[ "$pathDiff" == /Frameworks/* ]]
		then
			newname="@rpath/$(basename $target)"
			install_name_tool -add_rpath "@loader_path/" $file		
			echo "    This is a Framework, change its own id $target -> $newname" 
			
			install_name_tool -id \
			$newname \
			$target
		else
		    pathToFrameworks=$(echo $(dirname "${pathDiff}") | awk -F/ '{for (i = 1; i < NF ; i++) {printf("../")} }')
			pathToFrameworks="${pathToFrameworks}Frameworks/"
			install_name_tool -add_rpath "@loader_path/${pathToFrameworks}" $file
		fi
		
		for entry in $entries
		do
			baseEntry=$(basename $entry)
			newname=""
			newname="@rpath/${baseEntry}"
			echo "    change reference $entry -> $newname" 

			install_name_tool -change \
			$entry \
			$newname \
			$target

			addFileToCopy "$entry"
		done
		echo ""
		echo "   otool for $target after"
		otool -L $target | egrep -v "$IGNORED_OTOOL_OUTPUT" | awk '{printf("\t%s\n", $0)}'
	
	}

#This copies all of the files in the list into Frameworks
	function copyFilesToFrameworks
	{
		FILES_COPIED=0
		for libFile in "${FILES_TO_COPY[@]}"
		do
			# if it starts with a / then easy.
			#
			base=$(basename $libFile)

			if [[ $libFile == /* ]]
			then
				filename=$libFile
			else
				# see if I can find it, NOTE:  I had to add the last part and the echo because the find produced multiple results breaking the file copy into frameworks.
				filename=$(echo $(find "${CRAFT_DIR}/lib" -name "${base}")| cut -d" " -f1)
				if [[ "$filename" == "" ]]
				then
					filename=$(echo $(find /usr/local/lib -name "${base}")| cut -d" " -f1)
				fi
			fi    

			if [ ! -f "${FRAMEWORKS_DIR}/${base}" ]
			then
				echo "HAVE TO COPY [$base] from [${filename}] to Frameworks"
				cp -fL "${filename}" "${FRAMEWORKS_DIR}"
				
				FILES_COPIED=$((FILES_COPIED+1))
			
				# Seem to need this for the macqtdeploy
				#
				chmod +w "${FRAMEWORKS_DIR}/${base}"
		
			
			else
				echo ""
				echo "Skipping Copy: $libFile already in Frameworks "
			fi
		done
	}
	
	function processDirectory
	{
		directoryName=$1
		directory=$2
		echo "Processing all of the $directoryName files in $directory"
		FILES_TO_COPY=()
		for file in ${directory}/*
		do
    		base=$(basename $file)

        	echo "Processing $directoryName file $base"
        	processTarget $file
        	
		done

		echo "Copying required files for $directoryName into frameworks"
		copyFilesToFrameworks
	}
	
	
	
#########################################################################
#This is where the main part of the script starts!!
#

#check base directory
if [ -z "${ASTRO_ROOT}" ]
then
		echo "no root directory! aborting Libraries script!"
		exit 9
fi

#This should stop the script so that it doesn't run if these paths are blank.
#That way it doesn't try to edit /Applications instead of ${CRAFT_DIR}/Applications for example
	if [ -z  "${CRAFT_DIR}" ] || [ -z  "${DMG_DIR}" ] || [ -z  "${TARGET_APP}" ]
	then
		echo "directory error! aborting Libraries script!"
		exit 9
	fi

#This code should make sure the target app and the DMG Directory are set correctly.
	if [ ! -e ${CRAFT_DIR} ]
	then
		echo "Craft directory does not exist.  You have to build INDI with Craft first."
		exit 9
	fi
	if [ ! -e ${DMG_DIR} ]
	then
		echo "Target directory does not exist."
		exit 9
	fi
	if [ ! -e ${TARGET_APP} ]
	then
		echo "Target application does not exist."
		exit 9
	fi
	
echo "Running Fix Libraries Script"

	FILES_TO_COPY=()
	FRAMEWORKS_DIR="${TARGET_APP}/Contents/Frameworks"

#Files in these locations do not need to be copied into the Frameworks folder.
	IGNORED_OTOOL_OUTPUT="/Qt|${TARGET_APP}/|/usr/lib/|/System/"

#This deletes the former Frameworks folder so you can start fresh.  This is needed if it ran before.
	echo "Replacing the Frameworks Directory"
	rm -fr "${FRAMEWORKS_DIR}"
	mkdir -p "${FRAMEWORKS_DIR}"
	
	
cd ${DMG_DIR}

# Add libindidriver.1.dylib to the list
#
addFileToCopy "libindidriver.1.dylib"

echo "Copying first round of files"
copyFilesToFrameworks

echo "Processing libindidriver library"

# need to process libindidriver.1.dylib
#
processTarget "${FRAMEWORKS_DIR}/libindidriver.1.dylib"
processDirectory indi "${TARGET_APP}/Contents/MacOS/indi"

processDirectory GPHOTO_IOLIBS "${TARGET_APP}/Contents/Resources/DriverSupport/gphoto/IOLIBS"
processDirectory GPHOTO_CAMLIBS "${TARGET_APP}/Contents/Resources/DriverSupport/gphoto/CAMLIBS"

processDirectory MathPlugins "${TARGET_APP}/Contents/Resources/MathPlugins"

processDirectory Frameworks "${FRAMEWORKS_DIR}"

while [ ${FILES_COPIED} -gt 0 ]
do
	echo "${FILES_COPIED} more files were copied into Frameworks, we need to process it again."
	processDirectory Frameworks "${FRAMEWORKS_DIR}"
done

echo "The following files are now in Frameworks:"
ls -lF ${FRAMEWORKS_DIR}

