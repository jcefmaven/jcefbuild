#!/bin/bash
set -e

# Determine architecture
echo "Building for architecture $TARGETARCH"

if [ ! -f "/jcef/README.md" ]; then
    echo "Did not find existing files to build - cloning..."
    rm -rf /jcef
    git clone https://bitbucket.org/chromiumembedded/java-cef.git /jcef
    cd /jcef
    git checkout ${REF}
else
    echo "Found existing files to build"
    cd /jcef
fi

# Create and enter the `jcef_build` directory.
# The `jcef_build` directory name is required by other JCEF tooling
# and should not be changed.
mkdir jcef_build && cd jcef_build

# Linux: Generate 32/64-bit Unix Makefiles.
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=${BUILD_TYPE} ..
# Build native part using ninja.
ninja -j4

#Compile JCEF java classes
cd ../tools
chmod +x compile.sh
if [ ${TARGETARCH} == 'amd64' ]; then
    ./compile.sh linux64
else
    ./compile.sh linux32
fi

#Generate distribution
chmod +x make_distrib.sh
if [ ${TARGETARCH} == 'amd64' ]; then
    ./make_distrib.sh linux64
else
    ./make_distrib.sh linux32
fi

#Pack binary_distrib
if [ ${TARGETARCH} == 'amd64' ]; then
    cd ../binary_distrib/linux64
else
    cd ../binary_distrib/linux32
fi
tar -czvf ../../binary_distrib.tar.gz *
