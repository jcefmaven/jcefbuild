#!/bin/bash

if [ $# -lt 2 ] || [ $# -eq 3 ]
  then
    echo "Usage: ./compile_linux.sh <architecture> <buildType> [<gitrepo> <gitref>]"
    echo ""
    echo "architecture: the target architecture to build for. Architectures are either arm64, arm/v6, 386 or amd64."
    echo "buildType: either Release or Debug"
    echo "gitrepo: git repository url to clone"
    echo "gitref: the git commit id to pull"
    exit 1
fi

#Execute buildx with linux dockerfile and output to current directory
if [ $# -eq 2 ]
  then
    if [ $1 == "arm/v6" ]
      then
        docker buildx build --platform=linux/386 --build-arg TARGETARCH=386 --build-arg BUILD_TYPE=$2 --build-arg REPO=https://bitbucket.org/chromiumembedded/java-cef.git --build-arg REF=master --file DockerfileLinuxARMPrebuild --output out .
    fi
    docker buildx build --platform=linux/$1 --build-arg TARGETARCH=$1 --build-arg BUILD_TYPE=$2 --build-arg REPO=https://bitbucket.org/chromiumembedded/java-cef.git --build-arg REF=master --file DockerfileLinux --output out .
else
    if [ $1 == "arm/v6" ]
      then
        docker buildx build --platform=linux/386 --build-arg TARGETARCH=386 --build-arg BUILD_TYPE=$2 --build-arg REPO=$3 --build-arg REF=$4 --file DockerfileLinuxARMPrebuild --output out .
    fi
    docker buildx build --platform=linux/$1 --build-arg TARGETARCH=$1 --build-arg BUILD_TYPE=$2 --build-arg REPO=$3 --build-arg REF=$4 --file DockerfileLinux --output out .
fi
