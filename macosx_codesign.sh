#!/bin/bash

if [ $# -lt 5 ]
  then
    echo "Usage: ./macosx_codesign.sh <path> <certname> <teamname> <appleid> <applepwd>"
    echo ""
    echo "path: the absolute(!) target path"
    echo "certname: the apple signing certificate name. Something like \"Developer ID Application: xxx (yyy)\""
    echo "teamname: the apple team name. 10-digit id yyy from the cert name."
    echo "appleid: your apple developer id"
    echo "applepwd: your apple developer id password"
    exit 1
fi

#Set workdir local (for plist files)
cd "$( dirname "$0" )"
APP_DIR=$1/bin
APP_NAME=jcef_app.app
FRAMEWORKS_DIR=Contents/Frameworks
FRAMEWORK_NAME=Chromium\ Embedded\ Framework.framework
ENTITLEMENTS_HELPER=entitlements/entitlements-helper.plist
ENTITLEMENTS_BROWSER=entitlements/entitlements-browser.plist

chmod -R 777 $APP_DIR/$APP_NAME
chmod +x macosx_notarize.sh

#Sign helpers
echo "Signing helpers..."
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper.app"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper.app" $2 $3 org.jcef.jcef.helper $4 $5
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (GPU).app"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (GPU).app" $2 $3 org.jcef.jcef.helper.gpu $4 $5
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (Plugin).app"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (Plugin).app" $2 $3 org.jcef.jcef.helper.plugin $4 $5
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (Renderer).app"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (Renderer).app" $2 $3 org.jcef.jcef.helper.renderer $4 $5

#Sign libraries and framework
echo "Signing libraries and framework..."
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libEGL.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libGLESv2.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libswiftshader_libEGL.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libswiftshader_libGLESv2.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libvk_swiftshader.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME" $2 $3 org.cef.framework $4 $5
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/Contents/Java/libjcef.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME" $2 $3 org.jcef.jcef $4 $5

echo "Done signing binaries"
