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
    echo "Deprecation notice: The openliberty/open-liberty image will no longer be published to Docker Hub. Instead, pull from the IBM Container Registry using image icr.io/appcafe/open-liberty"
}

logDeprecationNotice

main