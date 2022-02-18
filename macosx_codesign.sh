#!/bin/bash

if [ $# -lt 2 ]
  then
    echo "Usage: ./macosxcodesign.sh <path> <certname> [<bundleid> <appleid> <applepwd>]"
    echo ""
    echo "path: the target path"
    echo "certname: the apple signing certificate name. Something like \"Developer ID Application: xxx\""
    exit 1
fi

#Set workdir local (for plist files)
cd "$( dirname "$0" )"
APP_DIR=$1/bin
APP_NAME=cef_app.app
FRAMEWORKS_DIR=Contents/Frameworks
FRAMEWORK_NAME=Chromium Embedded Framework.framework
ENTITLEMENTS_HELPER=entitlements/entitlements-helper.plist
ENTITLEMENTS_BROWSER=entitlements/entitlements-browser.plist

chmod -R 777 $APP_DIR/$APP_NAME

#Sign helpers
echo "Signing helpers..."
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper.app"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (GPU).app"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (Plugin).app"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (Renderer).app"

#Sign libraries and framework
echo "Signing libraries and framework..."
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libEGL.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libGLESv2.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libswiftshader_libEGL.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libswiftshader_libGLESv2.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libvk_swiftshader.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/Contents/Java/libjcef.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME"

echo "Done signing binaries"
