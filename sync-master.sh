#!/bin/sh

find library | grep docker-server | xargs -I % cp -a master/docker-server
find openliberty | grep docker-server | xargs -I % cp -a master/docker-server

find openliberty | grep README.md | xargs -I % cp -a master/README.md
