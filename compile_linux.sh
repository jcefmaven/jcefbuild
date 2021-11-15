#!/bin/bash

if [ $# -lt 2 ]
  then
    echo "Usage: ./compile_linux.sh <architecture> <buildType> [ref]"
    echo ""
    echo "architecture: the target architecture to build for. Architectures are either 386 or amd64."
    echo "buildType: either Release or Debug"
    echo "ref: the git commit id to pull"
    exit 1
fi

#Execute buildx with linux dockerfile and output to current directory
if [ $# -eq 2 ]
  then
    docker buildx build --platform=linux/$1 --build-arg TARGETARCH=$1 --build-arg BUILD_TYPE=$2 --build-arg REF=master --file DockerfileLinux --output out .
else
    docker buildx build --platform=linux/$1 --build-arg TARGETARCH=$1 --build-arg BUILD_TYPE=$2 --build-arg REF=$3 --file DockerfileLinux --output out .
fi
