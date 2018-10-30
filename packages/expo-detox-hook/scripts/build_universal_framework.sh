PROJECT=$1
OUTPUT_DIR=$2
CONFIGURATION=Release
PROJECT_NAME=ExpoDetoxHook

set -e

function remove_arch() {
    lipo -create "${1}" "${2}" -output "${3}"
}

# Make sure the output directory exists

mkdir -p "${OUTPUT_DIR}"
rm -fr "${OUTPUT_DIR}/${PROJECT_NAME}.framework"

TEMP_DIR=$(mktemp -d "$TMPDIR"ExpoDetoxHookBuild.XXXX)
echo TEMP_DIR = "${TEMP_DIR}"

# Step 1. Build Device and Simulator versions

BUILD_IOS=`xcodebuild -project "${PROJECT}" -UseNewBuildSystem=NO -scheme ExpoDetoxHook ONLY_ACTIVE_ARCH=NO -configuration "${CONFIGURATION}" -arch arm64 -sdk iphoneos VALID_ARCHS=arm64 -showBuildSettings  | awk -F= '/TARGET_BUILD_DIR/{x=$NF; gsub(/^[ \t]+|[ \t]+$/,"",x); print x}'`
BUILD_SIM=`xcodebuild -project "${PROJECT}" -UseNewBuildSystem=NO -scheme ExpoDetoxHook -configuration "${CONFIGURATION}" -arch x86_64 -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO VALID_ARCHS=x86_64 -showBuildSettings  | awk -F= '/TARGET_BUILD_DIR/{x=$NF; gsub(/^[ \t]+|[ \t]+$/,"",x); print x}'`

echo ${BUILD_IOS}
echo ${BUILD_SIM}

xcodebuild -project "${PROJECT}" -UseNewBuildSystem=NO -scheme ExpoDetoxHook ONLY_ACTIVE_ARCH=NO -configuration "${CONFIGURATION}" -arch arm64 -sdk iphoneos build VALID_ARCHS=arm64
xcodebuild -project "${PROJECT}" -UseNewBuildSystem=NO -scheme ExpoDetoxHook -configuration "${CONFIGURATION}" -arch x86_64 -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO build VALID_ARCHS=x86_64

# Step 2. Copy the framework structure (from iphoneos build) to the universal folder

cp -fR "${BUILD_IOS}/${PROJECT_NAME}.framework" "${TEMP_DIR}/"

echo $TEMP_DIR

# Step 3. Create universal binary file using lipo and place the combined executable in the copied framework directory

remove_arch "${BUILD_SIM}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_IOS}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${TEMP_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}"

mv "${TEMP_DIR}/${PROJECT_NAME}.framework" "${OUTPUT_DIR}"/
rm -fr "${TEMP_DIR}"
