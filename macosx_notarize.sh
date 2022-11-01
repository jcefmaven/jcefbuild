#!/bin/bash

#Contents partly stolen from https://scriptingosx.com/2019/09/notarize-a-command-line-tool/
#Will need updating for XCode 13+

if [ $# -lt 6 ]
  then
    echo "Usage: ./macosx_notarize.sh <path> <certname> <teamname> <bundleid> <applekeyid> <applekeyissuer>"
    echo ""
    echo "path: the absolute(!) target path"
    echo "certname: the apple signing certificate name. Something like \"Developer ID Application: xxx (yyy)\""
    echo "teamname: the apple team name. 10-digit id yyy from the cert name."
    echo "bundleid: the bundle id of the artifact"
    echo "applekeyid: your apple api key id"
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

echo "Uploading $ZIP_PATH for notarization"
xcRunOutput=$(xcrun altool --notarize-app \
                           --type macos \
                           --primary-bundle-id "$4" \
                           --apiKey "$5" \
                           --apiIssuer "$6" \
                           --file "$1.zip" 2>&1 )
echo "xcrun> $xcRunOutput"
requestUUID=$(echo "$xcRunOutput" | awk '/RequestUUID/ { print $NF; }')

echo "Notarization RequestUUID: $requestUUID"

# clean up zip
rm -f "$APP_NAME.zip"

if [[ $requestUUID == "" ]]; then 
        echo "Could not upload for notarization"
        exit 1
fi

# wait for status to be not "in progress" any more
request_status="in progress"
while [[ "$request_status" == "in progress" ]]; do
    echo -n "waiting... "
    sleep 60
    request_status=$(xcrun altool --notarization-info "$requestUUID" \
                              --apiKey "$5" \
                              --apiIssuer "$6" 2>&1 \
                 | awk -F ': ' '/Status:/ { print $2; }' )
    echo "$request_status"
done

# print status information
xcrun altool --notarization-info "$requestUUID" \
             --apiKey "$5" \
             --apiIssuer "$6"
echo

if [[ $request_status != "success" ]]; then
    echo "Could not notarize! ($request_status)"
    exit 1
fi

# staple
xcrun stapler staple "$1"

echo "##########################################################"
