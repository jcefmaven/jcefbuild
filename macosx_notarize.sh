#!/bin/bash

#Contents partly stolen from https://scriptingosx.com/2019/09/notarize-a-command-line-tool/
#Will need updating for XCode 13+

if [ $# -lt 7 ]
  then
    echo "Usage: ./macosx_notarize.sh <path> <certname> <teamname> <bundleid> <applekeyid> <applekeypath> <applekeyissuer>"
    echo ""
    echo "path: the absolute(!) target path"
    echo "certname: the apple signing certificate name. Something like \"Developer ID Application: xxx (yyy)\""
    echo "teamname: the apple team name. 10-digit id yyy from the cert name."
    echo "bundleid: the bundle id of the artifact"
    echo "applekeyid: id of your apple api key"
    echo "applekeypath: path to your apple api key"
    echo "applekeyissuer: uuid of your apple api key issuer"
    exit 1
fi

echo "##########################################################"
echo "Notarizing $1... This may take a while."

APP_DIR="$( dirname "$1" )"
APP_NAME="$( basename "$1" )"
ZIP_PATH=$1.zip

cd $APP_DIR
echo "Creating zip"
zip -r "$APP_NAME.zip" "$APP_NAME"

echo "Uploading $ZIP_PATH for notarization and waiting for result"
xcrun notarytool submit "$1.zip" \
                 --key $6 \
                 --key-id $5 \
                 --key-issuer $7 \
                 --wait

# staple
xcrun stapler staple "$1"

echo "##########################################################"
