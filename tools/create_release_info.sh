#!/bin/bash

if [ ! $# -eq 4 ]
  then
    echo "Usage: ./create_release_info.sh <gitrepo> <gitref> <actionsurl> <actionsrunnumber>"
    echo ""
    echo "gitrepo: git repository url to clone"
    echo "gitref: the git commit id to pull"
    echo "actionsurl: the url pointing to the builder job"
    echo "actionsrunnumber: the number of the current build"
    exit 1
fi

#Pull from git
git clone $1 jcef
cd jcef
git checkout $2

#Dump git commit id and suspected url
git rev-parse HEAD | cut -c -7 > ../commit_id.txt #Use short 7-digit commit id
(
  sed 's/\.git.*$//' <<< "$1" #Remove .git and everything behind from url
  echo "/commits/"
  git rev-parse HEAD          #Add commit id
) | awk '{print}' ORS='' > ../commit_url.txt #Remove newlines and pipe to file

#Dump git commit message
git log -1 --pretty=%B > ../commit_message.txt

#Dump cef version info
(grep -o -P '(?<=CEF_VERSION \").*(?=\")' < CMakeLists.txt) > ../cef_version.txt

#Build final release information
#Tag
(
  echo "release_tag_name="
  echo "jcef-"
  cat ../commit_id.txt
  echo "+cef-"
  cat ../cef_version.txt
) | awk '{print}' ORS='' >> $GITHUB_ENV
echo "" >> $GITHUB_ENV

#Name
(
  echo "release_name="
  echo "JCEF "
  cat ../commit_id.txt 
  echo " + CEF "
  cat ../cef_version.txt
) | awk '{print}' ORS='' >> $GITHUB_ENV 
echo "" >> $GITHUB_ENV

#Readme
(
  echo "Update JCEF to ["
  cat ../commit_id.txt
  echo "]("
  cat ../commit_url.txt
  echo ")"
  echo ""
  echo "Build: [GitHub Actions #$4]($3)"
  echo ""
  echo "JCEF version:"
  cat ../commit_id.txt
  echo ""
  echo "CEF version:"
  cat ../cef_version.txt
  echo ""
  echo "Changes from previous release:"
  echo "\`\`\`"
  cat ../commit_message.txt
  echo "\`\`\`"
) > ../release_message.md

#Add LICENSE
mv LICENSE.txt ..

#Build build_meta.json
#TODO

#Cleanup
cd ..
rm *.txt
rm -rf jcef
