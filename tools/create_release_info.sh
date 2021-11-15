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
  (
    echo "**Update JCEF to ["
    cat ../commit_id.txt
    echo "]("
    cat ../commit_url.txt
    echo ")**"
  ) | awk '{print}' ORS=''
  echo ""
  echo ""
  echo "Build: [GitHub Actions #$4]($3)"
  (
    echo "JCEF version: "
    cat ../commit_id.txt
  ) | awk '{print}' ORS=''
  echo ""
  (
    echo "CEF version: "
    cat ../cef_version.txt
  ) | awk '{print}' ORS=''
  echo ""
  echo ""
  echo "Changes from previous release:"
  echo "\`\`\`"
  cat ../commit_message.txt
  echo "\`\`\`"
  echo "**NOTE:** The sources appended below are the sources of this repository, not JCEF. Please refer to the JCEF commit linked above to obtain sources of this build."
) > ../release_message.md

#Add LICENSE
mv LICENSE.txt ../LICENSE

#Build build_meta.json
(
  echo "{"
  echo "\"jcef_repository\": \"$1\", "
  echo "\"jcef_commit\": \"" && cat ../commit_id.txt && echo "\", "
  echo "\"jcef_commit_long\": \"" && git rev-parse HEAD && echo "\", "
  echo "\"jcef_url\": \"" && cat ../commit_url.txt && echo "\", "
  echo "\"cef_version\": \"" && cat ../cef_version.txt && echo "\", "
  echo "\"actions_url\": \"$3\", "
  echo "\"actions_number\": \"$4\", "
  echo "\"filename_linux_amd64\": \"linux-amd64.tar.gz\", "
  echo "\"filename_linux_i386\": \"linux-i386.tar.gz\", "
  echo "\"filename_windows_amd64\": \"windows-amd64.tar.gz\", "
  echo "\"filename_windows_i386\": \"windows-i386.tar.gz\", "
  echo "\"filename_macosx_amd64\": \"macosx-amd64.tar.gz\", "
  echo "\"filename_macosx_arm64\": \"macosx-arm64.tar.gz\""
  echo "}"
) | awk '{print}' ORS='' > ../build_meta.json

#Cleanup
cd ..
rm *.txt
rm -rf jcef
