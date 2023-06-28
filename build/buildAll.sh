#!/bin/bash

currentRelease=$1
tests=(test-pet-clinic test-stock-quote test-stock-trader test-liberty-certificates)

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

if [[ $currentRelease =~ latest ]]
then
  # Expose issues relating to Liberty config caching
  echo "Update stock quote test with old 20140101 config "
  touch -t 201401010000.00 test-stock-quote/config/server.xml test-stock-quote/config/configDropins/defaults/keystore.xml

  #Test the image
  for test in "${tests[@]}"; do
    testBuild="./build.sh --dir=$test --dockerfile=Dockerfile --tag=$test"
    echo "Running build script for test - $testBuild"
    eval $testBuild
    if [ "$test" == "test-liberty-certificates" ]; then
      verifyCommand="./verifyLibertyCertificates.sh $test"
    elif
      verifyCommand="./verify.sh $test"
    fi
    echo "Running verify script - $verifyCommand"
    eval $verifyCommand
  done
fi
