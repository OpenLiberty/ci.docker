#!/bin/bash

# Builds all Open Liberty Docker images
#  values set below, or in arguments, will override the defaults set in the Dockerfiles, allowing for development builds

usage="Usage (all args optional): buildAll.sh --version=<version> --communityRepository=<communityRepository> --officialRepository=<officialRepository> --javaee8DownloadUrl=<javaee8 image download url> --runtimeDownloadUrl=<runtime image download url> --webprofile8DownloadUrl=<webprofile8 image download url>"

version=19.0.0.2
communityRepository=openliberty/open-liberty
officialRepository=open-liberty
javaee8DownloadUrl="https://repo1.maven.org/maven2/io/openliberty/openliberty-javaee8/${version}/openliberty-javaee8-${version}.zip"
runtimeDownloadUrl="https://repo1.maven.org/maven2/io/openliberty/openliberty-runtime/${version}/openliberty-runtime-${version}.zip"
webprofile8DownloadUrl="https://repo1.maven.org/maven2/io/openliberty/openliberty-webProfile8/${version}/openliberty-webProfile8-${version}.zip"

# values above can be overridden by optional arguments when this script is called
while [ $# -gt 0 ]; do
  case "$1" in
    --version=*)
      version="${1#*=}"
      ;;
    --communityRepository=*)
      communityRepository="${1#*=}"
      ;;
    --officialRepository=*)
      officialRepository="${1#*=}"
      ;;
    --javaee8DownloadUrl=*)
      javaee8DownloadUrl="${1#*=}"
      ;;
    --runtimeDownloadUrl=*)
      runtimeDownloadUrl="${1#*=}"
      ;;
    --webprofile8DownloadUrl=*)
      webprofile8DownloadUrl="${1#*=}"
      ;;
    *)
      echo "Error: Invalid argument - $1"
      echo "$usage"
      exit 1
  esac
  shift
done

# figure out the checksum for each image we will download
wget --progress=bar:force $javaee8DownloadUrl -U UA-Open-Liberty-Docker -O javaee8.zip
javaee8DownloadSha=$(sha1sum javaee8.zip | awk '{print $1;}')
rm -f javaee8.zip

wget --progress=bar:force $runtimeDownloadUrl -U UA-Open-Liberty-Docker -O runtime.zip
runtimeDownloadSha=$(sha1sum runtime.zip | awk '{print $1;}')
rm -f runtime.zip

wget --progress=bar:force $webprofile8DownloadUrl -U UA-Open-Liberty-Docker -O webprofile8.zip
webprofile8DownloadSha=$(sha1sum webprofile8.zip | awk '{print $1;}')
rm -f webprofile8.zip

# Builds up the build.sh call to build each individual docker image listed in images.txt
while read -r buildContextDirectory imageTag imageTag2 imageTag3
do
  buildCommand="./build.sh --dir=$buildContextDirectory --version=$version"

  if [[ $buildContextDirectory =~ community ]]
  then
    repository=$communityRepository
  else
    repository=$officialRepository
  fi
  buildCommand="$buildCommand --tag=$repository:$imageTag"
  if [ ! -z "$imageTag2" ]
  then
    buildCommand="$buildCommand --tag2=$repository:$imageTag2"
  fi
  if [ ! -z "$imageTag3" ]
  then
    buildCommand="$buildCommand --tag3=$repository:$imageTag3"
  fi

  if [[ $imageTag =~ javaee8 ]]
  then
    buildCommand="$buildCommand --imageSha=$javaee8DownloadSha --imageUrl=$javaee8DownloadUrl"
  elif [[ $imageTag =~ kernel ]]
  then
    buildCommand="$buildCommand --imageSha=$runtimeDownloadSha --imageUrl=$runtimeDownloadUrl"
  elif [[ $imageTag =~ webProfile8 ]]
  then
    buildCommand="$buildCommand --imageSha=$webprofile8DownloadSha --imageUrl=$webprofile8DownloadUrl"
  fi

  echo "Running build script - $buildCommand"
  eval $buildCommand

  if [ $? != 0 ]; then
    echo "Failed at image $imageTag ($buildContextDirectory) - exiting"
    exit 1
  fi
done < "images.txt"

