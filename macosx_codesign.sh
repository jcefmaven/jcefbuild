#!/bin/bash

if [ $# -lt 6 ]
  then
    echo "Usage: ./macosx_codesign.sh <path> <certname> <teamname> <applekeyid> <applekeypath> <applekeyissuer>"
    echo ""
    echo "path: the absolute(!) target path"
    echo "certname: the apple signing certificate name. Something like \"Developer ID Application: xxx (yyy)\""
    echo "teamname: the apple team name. 10-digit id yyy from the cert name."
    echo "applekeyid: id of your apple api key"
    echo "applekeypath: path to your apple api key"
    echo "applekeyissuer: uuid of your apple api key issuer"
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
chmod +x macosx_codesign_zip.sh

#Sign helpers
echo "Signing helpers..."
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper.app"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper.app" "$2" $3 org.jcef.jcef.helper $4 $5 $6
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (GPU).app"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (GPU).app" "$2" $3 org.jcef.jcef.helper.gpu $4 $5 $6
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (Plugin).app"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (Plugin).app" "$2" $3 org.jcef.jcef.helper.plugin $4 $5 $6
codesign --force --options runtime --entitlements "$ENTITLEMENTS_HELPER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (Renderer).app"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/jcef Helper (Renderer).app" "$2" $3 org.jcef.jcef.helper.renderer $4 $5 $6

#Sign libraries and framework
echo "Signing libraries and framework..."
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libEGL.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libGLESv2.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME/Libraries/libvk_swiftshader.dylib"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME/$FRAMEWORKS_DIR/$FRAMEWORK_NAME" "$2" $3 org.cef.framework $4 $5 $6
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME/Contents/Java/libjcef.dylib"
bash macosx_codesign_zip.sh "$APP_DIR/$APP_NAME/Contents/Java/gluegen-rt-natives-macosx-universal.jar" "natives/macosx-universal/libgluegen_rt.dylib" "$2"
bash macosx_codesign_zip.sh "$APP_DIR/$APP_NAME/Contents/Java/jogl-all-natives-macosx-universal.jar" "natives/macosx-universal/libnativewindow_awt.dylib" "$2"
bash macosx_codesign_zip.sh "$APP_DIR/$APP_NAME/Contents/Java/jogl-all-natives-macosx-universal.jar" "natives/macosx-universal/libnativewindow_macosx.dylib" "$2"
bash macosx_codesign_zip.sh "$APP_DIR/$APP_NAME/Contents/Java/jogl-all-natives-macosx-universal.jar" "natives/macosx-universal/libjogl_mobile.dylib" "$2"
bash macosx_codesign_zip.sh "$APP_DIR/$APP_NAME/Contents/Java/jogl-all-natives-macosx-universal.jar" "natives/macosx-universal/libnewt_head.dylib" "$2"
bash macosx_codesign_zip.sh "$APP_DIR/$APP_NAME/Contents/Java/jogl-all-natives-macosx-universal.jar" "natives/macosx-universal/libjogl_desktop.dylib" "$2"
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$2" --timestamp --verbose "$APP_DIR/$APP_NAME"
bash macosx_notarize.sh "$APP_DIR/$APP_NAME" "$2" $3 org.jcef.jcef $4 $5 $6

echo "Checking notarization validity"
spctl -vvv --assess --type exec "$APP_DIR/$APP_NAME"
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "Binaries are not correctly signed"
    exit 1
fi

echo "Done signing binaries"
