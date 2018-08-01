#!/bin/sh

find release | grep docker-server | xargs -I % cp -a master/docker-server
