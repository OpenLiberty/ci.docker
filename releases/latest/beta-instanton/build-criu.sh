#!/bin/bash

# To build criu you must have a download account with https://ftp3.rchland.ibm.com/myaccount/
# Your account must have access to Red Hat content
# The build machine must have access to the internal network
# You must pass in your ftpuser and ftppass as files that contain your ID and password
podman build --secret id=ftpuser,src=$1 --secret id=ftppass,src=$2 -t criu-build:ubi -f Dockerfile.criu.build.ubi .

container_id=$(podman create criu-build:ubi)
podman cp $container_id:/usr/local/sbin/criu criu
podman cp $container_id:/usr/local/lib64/libcriu.so.2.0 libcriu.so.2.0
podman rm -v $container_id

