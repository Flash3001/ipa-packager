#!/bin/bash
APP="$1"
IPA="$2"
TEMP_IPA_BUILT="/tmp/ipabuild"

XCODE_PATH="$3"
if [ ! -d "${XCODE_PATH}" ]; then
	echo "No developer directory found!"
	exit 1
fi

if [ ! -d "${APP}" ]; then
    echo "Usage: sh package_ipa.sh PATH_TO_SIGNED_APP OUTPUT_IPA_PATH"
    exit 1
fi

echo "+ Packaging ${APP} into ${IPA}"

if [ -f "${IPA}" ];
then
    /bin/rm "${IPA}"
fi    
if [ -d "${TEMP_IPA_BUILT}" ];
then
    rm -rf "${TEMP_IPA_BUILT}"
fi  

echo "+ Preparing folder tree for IPA" 
mkdir -p "${TEMP_IPA_BUILT}/Payload"
cp -Rp "${APP}" "${TEMP_IPA_BUILT}/Payload"

echo "+ Adding SWIFT support (if necessary)"
if [ -d "${APP}/Frameworks" ];
then
    mkdir -p "${TEMP_IPA_BUILT}/SwiftSupport"
    mkdir -p "${TEMP_IPA_BUILT}/SwiftSupport/iphoneos"

    for SWIFT_LIB in $(ls -1 "${APP}/Frameworks" | grep libswift); do
        echo "Copying ${SWIFT_LIB}"

        SOURCE="${XCODE_PATH}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphoneos/${SWIFT_LIB}"
        SWIFT_LIB_FULL_PATH="${APP}/Frameworks/${SWIFT_LIB}"

        ARC_TO_REMOVE=($(lipo "${SOURCE}" -archs))
        ARC_APP=($(lipo "${SWIFT_LIB_FULL_PATH}" -archs))

        for archApp in "${ARC_APP[@]}"; do 
            for i in "${!ARC_TO_REMOVE[@]}"; do 
                if [[ ${ARC_TO_REMOVE[i]} = "${archApp}" ]]; then
                    unset ARC_TO_REMOVE[i]
                fi
            done 
        done

        ARGS=()
        for i in "${!ARC_TO_REMOVE[@]}"; do
            ARGS+=" -remove ${ARC_TO_REMOVE[i]}"
        done

        if [ ${#ARGS[@]} == 0 ]; then
            ARGS+=" -create"
        fi

        lipo "${SOURCE}" ${ARGS} -output "${TEMP_IPA_BUILT}/SwiftSupport/iphoneos/${SWIFT_LIB}"
    done
fi

echo "+ zip --symlinks --verbose --recurse-paths ${IPA} ."
cd "${TEMP_IPA_BUILT}"
zip --symlinks --verbose --recurse-paths "${IPA}" .
