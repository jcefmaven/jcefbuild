#!/bin/bash

if [ ! $# -eq 2 ]
  then
    echo "Usage: ./compile_linux.sh <architecture> <buildType>"
    echo ""
    echo "architecture: the target architecture to build for. Architectures are the docker architectures (e.g. 386 or amd64)."
    echo "buildType: either Release or Debug"
    exit 1
fi

#Execute buildx with linux dockerfile and output to current directory
docker buildx build --platform=linux/$1 --build-arg TARGETARCH=$1 --build-arg BUILD_TYPE=$2 --file DockerfileLinux --output out .

