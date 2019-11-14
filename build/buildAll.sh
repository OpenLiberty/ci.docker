#!/bin/bash

tests=(test-pet-clinic test-stock-quote test-stock-trader)

# Builds up the build.sh call to build each individual docker image listed in images.txt
while read -r buildContextDirectory dockerfile repository imageTag imageTag2 imageTag3
do
  buildCommand="./build.sh --dir=$buildContextDirectory  --dockerfile=$dockerfile --tag=$repository:$imageTag"
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

  if [[ $buildContextDirectory =~ latest ]]
  then
    # Run through the tests for each of the `latest` tags
    for test in "${tests[@]}"; do
      testBuild="./build.sh --dir=$test --dockerfile=Dockerfile --tag=$test --from=$repository:$imageTag"
      echo "Running build script for test - $testBuild"
      eval $testBuild

      verifyCommand="./verify.sh $test"
      echo "Running verify script - $verifyCommand"
      eval $verifyCommand
    done
  fi

  if [ $? != 0 ]; then
    echo "Failed at image $imageTag ($buildContextDirectory) - exiting"
    exit 1
  fi
done < "images.txt"

