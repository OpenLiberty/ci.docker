#!/bin/bash

readonly TIMEOUT=3600

function keep_alive() {
  local i=0
  while [ $i -le $TIMEOUT ]; do
    local remaining=$(expr $TIMEOUT - $i)
    echo "*** $remaining seconds remain before timeout..."
    i=$(expr $i + 120)
    sleep 120
  done
}

cd releases/latest/kernel

echo "Build Context: $(pwd)"

docker buildx build \
  --progress plain  \
  --platform=linux/amd64,linux/s390x \
  -f Dockerfile.ubi.adoptopenjdk11 \
  .

echo "Build complete!"
