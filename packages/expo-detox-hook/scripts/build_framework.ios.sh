#!/bin/bash -e -x

# Ensure Xcode is installed or print a warning message and return.
xcodebuild -version &>/dev/null || { echo "WARNING: Xcode is not installed on this machine. Skipping iOS framework build phase"; exit 0; }

rootPath="$(dirname "$(dirname "$0")")"
version=`node -p "require('${rootPath}/package.json').version"`

sha1=`(echo "${version}" && xcodebuild -version) | shasum | awk '{print $1}' #"${2}"`
frameworkDirPath="$HOME/Library/ExpoDetoxHook/ios/${sha1}"
frameworkPath="${frameworkDirPath}/ExpoDetoxHook.framework"

function prepareAndBuildFramework () {
  if [ -d "$rootPath"/ios ]; then
    sourcePath="${rootPath}"/ios
    echo "Dev mode, will build from ${sourcePath}"
    buildFramework "${sourcePath}"
  else
    sourcePath="${rootPath}"/ios_src
    extractSources "${sourcePath}"
    buildFramework "${sourcePath}"
    rm -fr "${sourcePath}"
  fi
}

function extractSources () {
  sourcePath="${1}"
  echo "Extracting ExpoDetoxHook sources..."
  mkdir -p "${sourcePath}"
  tar -xjf "${rootPath}"/ExpoDetoxHook-ios-src.tbz -C "${sourcePath}"
}

function buildFramework () {
  sourcePath="${1}"
  echo "Building ExpoDetoxHook.framework from ${sourcePath}..."
  mkdir -p "${frameworkDirPath}"
  "${rootPath}"/scripts/build_universal_framework.sh "${sourcePath}"/ExpoDetoxHook.xcodeproj "${frameworkDirPath}" &> "${frameworkDirPath}"/expodetoxhook_ios.log
}

function main () {
  if [ -d "${frameworkDirPath}" ]; then
    if [ ! -d "${frameworkPath}" ]; then
      echo "${frameworkDirPath} was found, but could not find ExpoDetoxHook.framework inside it. This means that the ExpoDetoxHook framework build process was interrupted.
         deleting ${frameworkDirPath} and trying to rebuild."
      rm -rf "${frameworkDirPath}"
      prepareAndBuildFramework
    else
      echo "ExpoDetoxHook.framework was previously compiled, skipping..."
    fi
  else
    prepareAndBuildFramework
  fi

  echo "Done"
}

main
