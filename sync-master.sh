#!/bin/sh

find official | grep docker-server | xargs -I % cp -a common/docker-server
find community | grep docker-server | xargs -I % cp -a common/docker-server

find community | grep README.md | xargs -I % cp -a common/README.md
