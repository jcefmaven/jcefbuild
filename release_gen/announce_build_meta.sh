#!/bin/bash

if [ ! $# -eq 1 ]
  then
    echo "Usage: ./announce_build_meta.sh <releaserepo>"
    echo ""
    echo "releaserepo: Release repository on github - e.g. jcefmaven/jcefmaven"
    exit 1
fi

#Announce build_meta.json to other jobs
(
  echo "build_meta=https://github.com/$1/releases/download/"
  cat release_tag.txt
  echo "/build_meta.json"
) | awk '{print}' ORS='' >> $GITHUB_ENV
echo "" >> $GITHUB_ENV
