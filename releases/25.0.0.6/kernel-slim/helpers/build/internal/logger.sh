#!/bin/bash

function main() {
    if [ "$VERBOSE" != "true" ]; then
        exec >/dev/null
    fi
}

function hideLogs() {
    exec 3>&1 >/dev/null 4>&2 2>/dev/null
}

function showLogs() {
    exec 1>&3 3>&- 2>&4 4>&-
}

function logDeprecationNotice() {
    echo "Deprecation notice: IBM expects the last version of the UBI-based Open Liberty container images in Docker Hub ('openliberty/open-liberty') to be 25.0.0.3. To continue to receive updates and security fixes after 25.0.0.3, you must switch to using the images from the IBM Container Registry (ICR). To switch, simply update 'FROM openliberty/open-liberty' in your Dockerfiles to 'FROM icr.io/appcafe/open-liberty'. The same image tags from Docker Hub are also available in ICR. Ubuntu-based Liberty container images will continue to be available from Docker Hub. For more information, see https://ibm.biz/ol-ubi-containers-dh-deprecation"
}

logDeprecationNotice

main