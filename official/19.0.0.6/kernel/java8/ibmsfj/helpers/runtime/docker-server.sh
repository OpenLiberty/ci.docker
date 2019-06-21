#!/bin/sh

set -e

keystorePath="/config/configDropins/defaults/keystore.xml"

if [ "$KEYSTORE_REQUIRED" = "true" ]
then
  if [ "$1" = "server" ] || [ "$1" = "/opt/ol/wlp/bin/server" ]
  then
    if [ ! -e $keystorePath ]
    then
      # Generate the keystore.xml
      export PASSWORD=$(openssl rand -base64 32)
      XML="<server description=\"Default Server\"><keyStore id=\"defaultKeyStore\" password=\"$PASSWORD\" /></server>"

    # Create the keystore.xml file and place in configDropins
    mkdir -p $(dirname $keystorePath)
    echo $XML > $keystorePath
    fi
  fi
fi

# Pass on to the real server run
exec "$@"
