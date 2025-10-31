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

main