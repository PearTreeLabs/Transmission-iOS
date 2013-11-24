#!/bin/bash

# Usage
# ./build.sh <TARGET NAME>
#
# If no target is specified, it will be guessed from the environment.


# Expected Jenkins environment variables
# - WORKSPACE
# - BUILD_NUMBER
# - BUILD_CONFIGURATION

if [ "" = "$WORKSPACE" ]; then
  WORKSPACE=`pwd`
fi

if [ "" = "$BUILD_NUMBER" ]; then
  BUILD_NUMBER="0"
fi

if [ "" = "$BUILD_CONFIGURATION" ]; then
  BUILD_CONFIGURATION="Debug"
fi

TARGET=""
if [ "" != "$1" ]; then
  # Default
  TARGET="$1"
elif [ "" != "$JOB_NAME" ]; then
  # Default when not passed, but running from Jenkins
  TARGET="$JOB_NAME"
else
  # Default when not passed
  PWD=`pwd`
  TARGET=`basename $PWD`
fi

# Configuration
env
BUILD_DIR="$WORKSPACE/build"
TEST_REPORT_DIR="$WORKSPACE/test-reports"
PLATFORM="iphoneos"
KEYCHAIN="$HOME/Library/Keychains/login.keychain"

# Cleanup
if [ -d "$BUILD_DIR" ]; then
  echo "Cleaning build directory: $BUILD_DIR"
  rm -r "$BUILD_DIR"
fi

if [ -d "$TEST_REPORT_DIR" ]; then
  echo "Cleaning test reports: $TEST_REPORT_DIR"
  rm -r "$TEST_REPORT_DIR"
fi

# Setup
echo "Setting CFBundleVersion to $BUILD_NUMBER"
agvtool new-version -all "$BUILD_NUMBER"

echo "Unlocking the keychain"
KEYCHAIN_PASSWORD=`cat $HOME/.keychain_password`
security list-keychains -s "$KEYCHAIN"
security default-keychain -d user -s "$KEYCHAIN"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN"

# Building
echo "Cleaning and building $TARGET - $BUILD_CONFIGURATION"
xcodebuild -target "$TARGET" -configuration "$BUILD_CONFIGURATION" clean build

# Packaging
OUTPUT_DIR="$BUILD_DIR/$BUILD_CONFIGURATION-$PLATFORM"
cd "$OUTPUT_DIR"

echo "Packaging IPA"
APP_NAME="$TARGET.app"
IPA_NAME="$TARGET-$BUILD_CONFIGURATION-$BUILD_NUMBER.ipa"
xcrun -sdk iphoneos PackageApplication -v "$OUTPUT_DIR/$APP_NAME" -o "$OUTPUT_DIR/$IPA_NAME"
export PACKAGED_IPA_PATH="$OUTPUT_DIR/$IPA_NAME"

echo "Packaging dSYM"
DSYM_NAME="$TARGET.app.dSYM"
ZIP_NAME="$TARGET-$BUILD_CONFIGURATION-$BUILD_NUMBER-dSYM.zip"
zip -r -T -y "$ZIP_NAME" "$OUTPUT_DIR/$DSYM_NAME"
export PACKAGED_DSYM_PATH="$OUTPUT_DIR/$ZIP_NAME"

# Deployment

cd "$WORKSPACE"
if [ -f "deploy.sh" ]; then
  ./deploy.sh
fi
