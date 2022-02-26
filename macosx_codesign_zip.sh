#!/bin/bash

if [ $# -lt 3 ]
  then
    echo "Usage: ./macosx_codesign_zip.sh <path> <zippath> <certname>"
    echo ""
    echo "path: the absolute(!) target path"
    echo "zippath: the path inside the zip"
    echo "certname: the apple signing certificate name. Something like \"Developer ID Application: xxx (yyy)\""
    exit 1
fi

#Set workdir local
cd "$( dirname "$0" )"
ENTITLEMENTS_BROWSER=entitlements/entitlements-browser.plist

mkdir tmp
unzip "$1" "$2" -d tmp
codesign --force --options runtime --entitlements "$ENTITLEMENTS_BROWSER" --sign "$3" --timestamp --verbose "tmp/$2"
cd tmp
zip --update "$1" "$2"
cd ..
rm -rf tmp
