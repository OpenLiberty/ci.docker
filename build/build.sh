#!/bin/bash

# Builds a single Open Liberty Docker Image
#  dir and tag must be specified, other arguments allow for overrides in development builds.

usage="Usage: build.sh --dir=<Dockerfile directory> --tag=<image tag name> (--tag2=<second image tag name> --tag3=<third image tag name> --version <product version> --imageSha=<image sha> --imageUrl=<image download url>)"

while [ $# -gt 0 ]; do
  case "$1" in
    --dir=*)
      dir="${1#*=}"
      ;;
    --tag=*)
      tag="${1#*=}"
      ;;
    --tag2=*)
      tag2="${1#*=}"
      ;;
    --tag3=*)
      tag3="${1#*=}"
      ;;
    --version=*)
      version="${1#*=}"
      ;;
    --imageSha=*)
      imageSha="${1#*=}"
      ;;
    --imageUrl=*)
      imageUrl="${1#*=}"
      ;;
    *)
      echo "Error: Invalid argument - $1"
      echo "$usage"
      exit 1
  esac
  shift
done

if [ -z "$dir" ] || [ -z "$tag" ]
then
  echo "Error: Must specify --dir and --tag args"
  echo "$usage"
  exit 1
fi

buildCommand="docker build -t $tag"
if [ ! -z "$tag2" ]
then
  buildCommand="$buildCommand -t $tag2"
fi
if [ ! -z "$tag3" ]
then
  buildCommand="$buildCommand -t $tag3"
fi
if [ ! -z "$version" ]
then
  buildCommand="$buildCommand --build-arg LIBERTY_VERSION=${version}"
fi
if [ ! -z "$imageSha" ]
then
  buildCommand="$buildCommand --build-arg LIBERTY_SHA=${imageSha}"
fi
if [ ! -z "$imageUrl" ]
then
  buildCommand="$buildCommand --build-arg LIBERTY_DOWNLOAD_URL=${imageUrl}"
fi
buildCommand="$buildCommand $dir"

echo "****"
echo "Building $dir ($tag $tag2 $tag3)"
echo "$buildCommand"
echo "****"
eval $buildCommand

if [ $? = 0 ]
then
  echo "****"
  echo "Build successful $dir ($tag $tag2 $tag3)"
  echo "****"
else
  echo "Build failed $dir ($tag $tag2 $tag3), exiting."
  exit 1
fi
