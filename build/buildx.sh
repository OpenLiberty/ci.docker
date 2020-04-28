#!/bin/bash

cd releases/latest/kernel

echo "Build Context: $(pwd)"

docker buildx build \
  --progress plain  \
  --platform=linux/amd64,linux/ppc64le,linx/s390x \
  -f Dockerfile.ubi.adoptopenjdk11 \
  .

echo "Build complete!"
