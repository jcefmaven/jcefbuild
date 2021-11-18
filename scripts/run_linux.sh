#!/bin/bash
set -e

# Determine architecture
echo "Building for architecture $TARGETARCH"

# Point to jdk installation on arm/v6
if [ ${TARGETARCH} == 'arm/v6' ]; then
    export PATH=/usr/lib/jvm/openjdk-11-jdk/bin:$PATH
    export JAVA_HOME=/usr/lib/jvm/openjdk-11-jdk
fi

# Print some debug info
echo "-------------------------------------"
echo "JAVA_HOME: $JAVA_HOME"
echo "PATH: $PATH"
java -version
echo "-------------------------------------"

# Fetch sources
if [ ! -f "/jcef/README.md" ]; then
    echo "Did not find existing files to build - cloning..."
    rm -rf /jcef
    git clone ${REPO} /jcef
    cd /jcef
    git checkout ${REF}
    #Temporary CMakeLists patching - beautify in the future
    rm CMakeLists.txt
    curl -o CMakeLists.txt https://raw.githubusercontent.com/jcefmaven/jcefbuild/master/CMakeLists.txt
else
    echo "Found existing files to build"
    cd /jcef
fi

# Create and enter the `jcef_build` directory.
# The `jcef_build` directory name is required by other JCEF tooling
# and should not be changed.
mkdir jcef_build && cd jcef_build

# Linux: Generate 32/64-bit Unix Makefiles.
cmake -G "Ninja" -DPROJECT_ARCH=${TARGETARCH} -DCMAKE_BUILD_TYPE=${BUILD_TYPE} ..
# Build native part using ninja.
ninja -j4

#Compile JCEF java classes
cd tools
chmod +x compile.sh
if [ ${TARGETARCH} == 'amd64' ] || [ ${TARGETARCH} == 'arm64' ]; then
    ./compile.sh linux64
else
    ./compile.sh linux32
fi

#Generate distribution
chmod +x make_distrib.sh
if [ ${TARGETARCH} == 'amd64' ] || [ ${TARGETARCH} == 'arm64' ]; then
    ./make_distrib.sh linux64
else
    ./make_distrib.sh linux32
fi

#Pack binary_distrib
if [ ${TARGETARCH} == 'amd64' ] || [ ${TARGETARCH} == 'arm64' ]; then
    cd ../binary_distrib/linux64
    if [ ${BUILD_TYPE} == 'Release' ]; then (echo "Stripping binary..." && strip bin/lib/linux64/libcef.so) fi
else
    cd ../binary_distrib/linux32
    if [ ${BUILD_TYPE} == 'Release' ]; then (echo "Stripping binary..." && strip bin/lib/linux32/libcef.so) fi
fi
tar -czvf ../../binary_distrib.tar.gz *
