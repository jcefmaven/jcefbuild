#!/bin/bash

# Determine architecture
echo "Building for architecture $TARGETARCH"

# Point to jdk installation on arm/v6
if [ ${TARGETARCH} == 'arm/v6' ]; then
    export PATH=$PATH:/usr/lib/jvm/java-11-openjdk-armel/bin
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-armel
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
else
    echo "Found existing files to build"
    cd /jcef
fi  

#CMakeLists patching
python3 /builder/patch_cmake.py CMakeLists.txt /builder/CMakeLists.txt.patch

# Create and enter the `jcef_build` directory.
# The `jcef_build` directory name is required by other JCEF tooling
# and should not be changed.
if [ ! -d "jcef_build" ]; then
    mkdir jcef_build
fi
cd jcef_build

# Check if the download was already performed. If so, we wont send it outside of the container at the end
export already_downloaded=0
for f in ../third_party/cef/cef_binary_*; do
    test -d "$f" || continue
    #We found a matching dir
    export already_downloaded=1
    break
done

# Linux: Generate 32/64-bit Unix Makefiles.
cmake -G "Ninja" -DPROJECT_ARCH=${TARGETARCH} -DCMAKE_BUILD_TYPE=${BUILD_TYPE} ..
# Build native part using ninja.
ninja -j4

#Compile JCEF java classes
cd ../tools
chmod +x compile.sh
if [ ${TARGETARCH} == 'amd64' ] || [ ${TARGETARCH} == 'arm64' ]; then
    ./compile.sh linux64
elif [ ${TARGETARCH} == '386' ]; then
    echo "386 is no longer supported since chromium 104"
    exit 1
else
    echo "Can not compile java classes under arm/v6 currently. So we copy from prebuild directory."
    mkdir -p /jcef/out/linux32
    cp -r /prebuild/* /jcef/out/linux32/
fi

#Entering distribution phase - disable error handling (javadoc building fails here nontheless)
set -e

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
    #Replace natives on arm64
    if [ ${TARGETARCH} == 'arm64' ]; then (rm bin/gluegen-rt-natives* && rm bin/jogl-all-natives* && cp /natives/gluegen-rt-natives-linux-aarch64.jar bin && cp /natives/jogl-all-natives-linux-aarch64.jar bin) fi
else
    cd ../binary_distrib/linux32
    if [ ${BUILD_TYPE} == 'Release' ]; then (echo "Stripping binary..." && strip bin/lib/linux32/libcef.so) fi
    #Replace natives on armv6
    if [ ${TARGETARCH} == 'arm/v6' ]; then (rm bin/gluegen-rt-natives* && rm bin/jogl-all-natives* && cp /natives/gluegen-rt-natives-linux-armv6hf.jar bin && cp /natives/jogl-all-natives-linux-armv6hf.jar bin) fi
fi

#Export binaries
tar -czvf ../../binary_distrib.tar.gz *
mkdir ../../target
mv * ../../target

#Do not export third_party if already exported (it is quite large)
if [ "$already_downloaded" -eq "1" ]; then
    rm -rf ../../third_party/*
fi

#Export clang
mv ../../tools/buildtools/linux64 ../../buildtools
