#!/bin/bash

function main() {
    WLP_TYPE=ol
    WLP_INSTALL_DIR=/opt/$WLP_TYPE/wlp
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

function installFixes() {
    if [ ! -f "/logs/fixes.log" ] && ls "/opt/$WLP_TYPE/fixes"/*.jar 1> /dev/null 2>&1; then
        find /opt/$WLP_TYPE/fixes -type f -name "*.jar"  -print0 | sort -z | xargs -0 -n 1 -r -I {} java -jar {} --installLocation $WLP_INSTALL_DIR
        echo "installFixes has been run" > /logs/fixes.log
    fi 
}

function removeBuildArtifacts() {
    rm -f /logs/fixes.log
}

main