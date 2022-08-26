#!/bin/bash

if [ ! $# -eq 5 ]
  then
    echo "Usage: ./create_release_info.sh <gitrepo> <gitref> <actionsurl> <actionsrunnumber> <releaserepo>"
    echo ""
    echo "gitrepo: git repository url to clone"
    echo "gitref: the git commit id to pull"
    echo "actionsurl: the url pointing to the builder job"
    echo "actionsrunnumber: the number of the current build"
    echo "releaserepo: Release repository on github - e.g. jcefmaven/jcefmaven"
    exit 1
fi

#Remove text files from last run
rm -f *.txt

#Pull from git
git clone $1 jcef
cd jcef
git checkout $2

#Dump git commit id and suspected url
commit_id=$(git rev-parse HEAD | cut -c -7) #Use short 7-digit commit id
commit_id_long=$(git rev-parse HEAD)
commit_url=$(
  (
    sed 's/\.git.*$//' <<< "$1"      #Remove .git and everything behind from url
    echo "/commits/$commit_id_long"  #Add long commit id
  ) | awk '{print}' ORS=''           #Remove newlines
)

#Dump git commit message
commit_message=$(git log -1 --pretty=%B)

#Dump cef version info
cef_version=$(grep -o -P '(?<=CEF_VERSION \").*(?=\")' < CMakeLists.txt)

#Build final release information
#Tag
release_tag=$(echo "1.0.$4" | awk '{print}' ORS='')
real_release_tag=$(echo "jcef-$commit_id+cef-$cef_version" | awk '{print}' ORS='')
echo "$release_tag" > ../release_tag.txt #Export for build_meta announcer

echo "release_tag_name=$release_tag" >> $GITHUB_ENV

#Name
echo "release_name=JCEF $commit_id + CEF $cef_version" >> $GITHUB_ENV 

#Readme
(
  echo "**Update JCEF to [$commit_id]($commit_url)**"
  echo ""
  echo "Build: [GitHub Actions #$4]($3)"
  echo "JCEF version: $commit_id"
  echo "CEF version: $cef_version"
  echo ""
  echo "Changes from previous release:"
  echo "\`\`\`"
  echo "$commit_message"
  echo "\`\`\`"
  echo "**NOTE:** The sources appended below are the sources of this repository, not JCEF. Please refer to the JCEF commit linked above to obtain sources of this build."
) > ../release_message.md

#Add LICENSE
mv LICENSE.txt ../LICENSE

#Build build_meta.json
(
  echo "{"
  echo "  \"jcef_repository\": \"$1\", "
  echo "  \"jcef_commit\": \"$commit_id\", "
  echo "  \"jcef_commit_long\": \"$commit_id_long\", "
  echo "  \"jcef_url\": \"$commit_url\", "
  echo "  \"cef_version\": \"$cef_version\", "
  echo "  \"actions_url\": \"$3\", "
  echo "  \"actions_number\": \"$4\", "
  echo "  \"filename_linux_amd64\": \"linux-amd64.tar.gz\", "
  echo "  \"filename_linux_arm64\": \"linux-arm64.tar.gz\", "
  echo "  \"filename_linux_arm\": \"linux-arm.tar.gz\", "
  echo "  \"filename_windows_amd64\": \"windows-amd64.tar.gz\", "
  echo "  \"filename_windows_i386\": \"windows-i386.tar.gz\", "
  echo "  \"filename_windows_arm64\": \"windows-arm64.tar.gz\", "
  echo "  \"filename_macosx_amd64\": \"macosx-amd64.tar.gz\", "
  echo "  \"filename_macosx_arm64\": \"macosx-arm64.tar.gz\", "
  echo "  \"filename_javadoc\": \"javadoc.tar.gz\", "
  echo "  \"release_tag\": \"$real_release_tag\","
  echo "  \"release_url\": \"https://github.com/$5/releases/tag/$release_tag\", "
  echo "  \"download_url_linux_amd64\": \"https://github.com/$5/releases/download/$release_tag/linux-amd64.tar.gz\", "
  echo "  \"download_url_linux_arm64\": \"https://github.com/$5/releases/download/$release_tag/linux-arm64.tar.gz\", "
  echo "  \"download_url_linux_arm\": \"https://github.com/$5/releases/download/$release_tag/linux-arm.tar.gz\", "
  echo "  \"download_url_windows_amd64\": \"https://github.com/$5/releases/download/$release_tag/windows-amd64.tar.gz\", "
  echo "  \"download_url_windows_i386\": \"https://github.com/$5/releases/download/$release_tag/windows-i386.tar.gz\", "
  echo "  \"download_url_windows_arm64\": \"https://github.com/$5/releases/download/$release_tag/windows-arm64.tar.gz\", "
  echo "  \"download_url_macosx_amd64\": \"https://github.com/$5/releases/download/$release_tag/macosx-amd64.tar.gz\", "
  echo "  \"download_url_macosx_arm64\": \"https://github.com/$5/releases/download/$release_tag/macosx-arm64.tar.gz\", "
  echo "  \"download_url_javadoc\": \"https://github.com/$5/releases/download/$release_tag/javadoc.tar.gz\""
  echo "}"
) > ../build_meta.json

#Cleanup
cd ..
rm -rf jcef
