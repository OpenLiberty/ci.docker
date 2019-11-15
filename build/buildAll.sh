#!/bin/bash

currentRelease=$1

echo "Starting to process release $currentRelease"

# Builds up the build.sh call to build each individual docker image listed in images.txt
while read -r buildContextDirectory dockerfile repository imageTag imageTag2 imageTag3
do
  buildCommand="./build.sh --dir=$currentRelease/$buildContextDirectory  --dockerfile=$dockerfile --tag=$repository:$imageTag"
  if [ ! -z "$imageTag2" ]
  then
    buildCommand="$buildCommand --tag2=$repository:$imageTag2"
  fi
  if [ ! -z "$imageTag3" ]
  then
    buildCommand="$buildCommand --tag3=$repository:$imageTag3"
  fi
  echo "Running build script - $buildCommand"
  eval $buildCommand

  if [ $? != 0 ]; then
    echo "Failed at image $imageTag ($buildContextDirectory) - exiting"
    exit 1
  fi
done < "$currentRelease/images.txt"

