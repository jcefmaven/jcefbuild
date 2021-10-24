#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Usage: ./compile_linux.sh <architecture> [GYP_DEFINES]"
    echo ""
    echo "architecture: the target architecture to build for. Architectures are the docker architectures (e.g. 386 or amd64)."
    echo "GYP_DEFINES: When defined, performs a manual CEF build. Can be used to enable proprietary codec support. Wrap value with quotation marks."
    echo "    To enable proprietary codecs use: proprietary_codecs=1 ffmpeg_branding=Chrome"
    exit 1
fi

#Execute buildx with linux dockerfile and output to current directory
docker buildx build . --file DockerfileLinux --output out .

