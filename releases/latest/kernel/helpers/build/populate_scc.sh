#!/bin/bash
set -Eeox pipefail

SCC_SIZE="$1" # Size of the SCC layer
ITERATIONS="$2" # Number of iterations to run to populate it

# Make sure the following Java commands don't disturb our class cache until we're ready to populate it
# by unsetting IBM_JAVA_OPTIONS if it is currently defined.
unset IBM_JAVA_OPTIONS

# Explicity create a class cache layer for this image layer here rather than allowing
# `server start` to do it, which will lead to problems because multiple JVMs will be started.
java -Xshareclasses:name=liberty,cacheDir=/output/.classCache/,createLayer -Xscmx$SCC_SIZE -version

# Populate the newly created class cache layer.
export IBM_JAVA_OPTIONS="-Xshareclasses:name=liberty,cacheDir=/output/.classCache/"

# Server start/stop to populate the /output/workarea and make subsequent server starts faster
for ((i=0; i<$ITERATIONS; i++))
do
  /opt/ol/wlp/bin/server start && /opt/ol/wlp/bin/server stop
done

rm -rf /output/messaging /logs/* $WLP_OUTPUT_DIR/.classCache && chmod -R g+rwx /opt/ol/wlp/output/*
