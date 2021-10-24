#!/bin/bash
set -e

# Determine architecture
MACHINE_TYPE=`uname -m`
echo "Building for architecture $MACHINE_TYPE"

if [ ! -f "/jcef/README.md" ]; then
    echo "Did not find existing files to build - cloning..."
    git clone https://bitbucket.org/chromiumembedded/java-cef.git /jcef
else
    echo "Found existing files to build"
fi

# Enter the JCEF source code directory.
cd /jcef

# Create and enter the `jcef_build` directory.
# The `jcef_build` directory name is required by other JCEF tooling
# and should not be changed.
mkdir jcef_build && cd jcef_build

# Linux: Generate 32/64-bit Unix Makefiles.
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release ..
# Build native part using ninja.
ninja -j4

#Compile JCEF java classes
cd ../tools
chmod +x compile.sh
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    ./compile.sh linux64
else
    ./compile.sh linux32
fi

#Generate distribution
chmod +x make_distrib.sh
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    ./make_distrib.sh linux64
else
    ./make_distrib.sh linux32
fi


