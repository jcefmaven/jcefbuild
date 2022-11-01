#!/bin/bash

if [ $# -lt 2 ] || [ $# -eq 3 ]
  then
    echo "Usage: ./compile_macosx.sh <architecture> <buildType> [<gitrepo> <gitref>] [<certname> <teamname> <applekeyid> <applekeypath> <applekeyissuer>]"
    echo ""
    echo "architecture: the target architecture to build for. Architectures are either amd64 or arm64."
    echo "buildType: either Release or Debug"
    echo "gitrepo: git repository url to clone"
    echo "gitref: the git commit id to pull"
    echo "certname: the apple signing certificate name. Something like \"Developer ID Application: xxx (yyy)\""
    echo "teamname: the apple team name. 10-digit id yyy from the cert name."
    echo "applekeyid: id of your apple api key"
    echo "applekeypath: path to your apple api key"
    echo "applekeyissuer: uuid of your apple api key issuer"
    exit 1
fi

cd "$( dirname "$0" )"
WORK_DIR=$(pwd)

TARGETARCH=$1
BUILD_TYPE=$2
if [ $# -lt 4 ]
  then
    REPO=https://bitbucket.org/chromiumembedded/java-cef.git
    REF=master
else
    REPO=$3
    REF=$4
fi

# Determine architecture
echo "Building for architecture $TARGETARCH"

if [ ! -f "jcef/README.md" ]; then
    echo "Did not find existing files to build - cloning..."
    rm -rf jcef
    git clone ${REPO} jcef
    cd jcef
    git checkout ${REF}
    #No CMakeLists patching required on macos, as we do not add any new platforms
else
    echo "Found existing files to build"
    cd jcef
fi

# Create and enter the `jcef_build` directory.
# The `jcef_build` directory name is required by other JCEF tooling
# and should not be changed.
if [ ! -d "jcef_build" ]; then
    mkdir jcef_build
fi
cd jcef_build

# MacOS: Generate amd64/arm64 Makefiles.
if [ ${TARGETARCH} == 'amd64' ]; then
    cmake -G "Ninja" -DPROJECT_ARCH="x86_64" -DCMAKE_BUILD_TYPE=${BUILD_TYPE} ..
else
    cmake -G "Ninja" -DPROJECT_ARCH="arm64" -DCMAKE_BUILD_TYPE=${BUILD_TYPE} ..
fi
# Build native part using ninja.
ninja -j4

#Generate distribution
cd ../tools
chmod +x make_distrib.sh
./make_distrib.sh macosx64
cd ..

#Perform code signing
cd binary_distrib/macosx64
if [ $# -gt 4 ]
  then
    chmod +x $WORK_DIR/macosx_codesign.sh
    bash $WORK_DIR/macosx_codesign.sh $(pwd) "$5" $6 $7 $8 $9
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "Binaries are not correctly signed"
        exit 1
    fi
fi

#Pack binary_distrib
rm -rf ../../../out
mkdir ../../../out
tar -czvf ../../../out/binary_distrib.tar.gz *

#Pack javadoc
cd docs
tar -czvf ../../../../out/javadoc.tar.gz *
