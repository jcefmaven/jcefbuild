#!/bin/bash
set -e

if [ ! $# -eq 2 ]
  then
    echo "Usage: ./compile_macosx.sh <architecture> <buildType>"
    echo ""
    echo "architecture: the target architecture to build for. Architectures are either amd64 or arm64."
    echo "buildType: either Release or Debug"
    exit 1
fi

TARGETARCH=$1
BUILD_TYPE=$2

# Determine architecture
echo "Building for architecture $TARGETARCH"

if [ ! -f "jcef/README.md" ]; then
    echo "Did not find existing files to build - cloning..."
    rm -rf jcef
    git clone https://bitbucket.org/chromiumembedded/java-cef.git jcef
else
    echo "Found existing files to build"
fi

# Enter the JCEF source code directory.
cd jcef

# Create and enter the `jcef_build` directory.
# The `jcef_build` directory name is required by other JCEF tooling
# and should not be changed.
mkdir jcef_build && cd jcef_build

# MacOS: Generate amd64/arm64 Makefiles.
export CXXFLAGS+=-Wno-deprecated-copy
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

#Pack binary_distrib
cd ../binary_distrib/macosx64
mkdir ../../out
tar -czvf ../../out/binary_distrib.tar.gz *
