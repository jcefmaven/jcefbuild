#!/bin/bash

if [ $# -lt 2 ] || [ $# -eq 3 ]
  then
    echo "Usage: ./compile_linux.sh <architecture> <buildType> [<gitrepo> <gitref>]"
    echo ""
    echo "architecture: the target architecture to build for. Architectures are either arm64, arm/v6 or amd64."
    echo "buildType: either Release or Debug"
    echo "gitrepo: git repository url to clone"
    echo "gitref: the git commit id to pull"
    exit 1
fi

cd "$( dirname "$0" )"

#Remove old build output
rm -rf out
mkdir out
mkdir out/linux32
touch out/linux32/prebuilt.txt

#Remove binary distribution if there was one built before (saves transfer of it to docker context)
rm -rf jcef/binary_distrib

#Cache build image to not download it again each time (speedup for local builds)
docker pull friwidev/jcefdocker:linux-latest

#Execute buildx with linux dockerfile and output to current directory
if [ $# -eq 2 ]
  then
    if [ $1 == "arm/v6" ]
      then
        rm -rf out/linux32
        docker buildx build --no-cache --progress=plain --platform=linux/386 --build-arg TARGETARCH=386 --build-arg BUILD_TYPE=$2 --build-arg REPO=https://bitbucket.org/chromiumembedded/java-cef.git --build-arg REF=master --file DockerfileLinuxARMPrebuild --output out .
    fi
    docker buildx build --no-cache --progress=plain --platform=linux/$1 --build-arg TARGETARCH=$1 --build-arg BUILD_TYPE=$2 --build-arg REPO=https://bitbucket.org/chromiumembedded/java-cef.git --build-arg REF=master --file DockerfileLinux --output out .
else
    if [ $1 == "arm/v6" ]
      then
        rm -rf out/linux32
        docker buildx build --no-cache --progress=plain --platform=linux/386 --build-arg TARGETARCH=386 --build-arg BUILD_TYPE=$2 --build-arg REPO=$3 --build-arg REF=$4 --file DockerfileLinuxARMPrebuild --output out .
    fi
    docker buildx build --no-cache --progress=plain --platform=linux/$1 --build-arg TARGETARCH=$1 --build-arg BUILD_TYPE=$2 --build-arg REPO=$3 --build-arg REF=$4 --file DockerfileLinux --output out .
fi
docker builder prune -f --filter "label=jcefbuild=true"

#Cleanup output dir
rm -rf out/linux32
rm -f out/third_party/cef/*.bz2 out/third_party/cef/*.sha1

# Check if the cef download was performed. If so, move third_party dir to jcef dir
export downloaded=0
for f in out/third_party/cef/cef_binary_*; do
    test -d "$f" || continue
    #We found a matching dir
    export downloaded=1
    break
done
if [ "$downloaded" -eq "1" ]; then
    rm -rf jcef/third_party
    mv out/third_party jcef
else
    rm -rf out/third_party
fi

# Check if the clang download was performed. If so, move it to jcef dir
if [ -f "out/buildtools/clang-format" ]; then
    rm -rf jcef/tools/buildtools/linux64
    mv out/buildtools jcef/tools/buildtools/linux64
fi

#Move jcef_build
if [ -f "out/jcef_build" ]; then
    rm -rf jcef/jcef_build
    mv out/jcef_build jcef/jcef_build
fi

#Move target to binary_distrib
if [ -f "out/target" ]; then
    rm -rf jcef/binary_distrib
    mv out/target jcef/binary_distrib
fi
