#!/bin/sh

set -e

SNIPPETS_SOURCE=/opt/ol/helpers/build/configuration_snippets
SNIPPETS_TARGET=/config/configDropins/overrides

keystorePath="$SNIPPETS_TARGET/keystore.xml"

if [ "$KEYSTORE_REQUIRED" = "true" ]
then
  if [ "$1" = "server" ] || [ "$1" = "/opt/ol/wlp/bin/server" ]
  then
    # Check if the password is set already
    if [ ! -e $keystorePath ]
    then
      # Generate the keystore.xml
      export KEYSTOREPWD=$(openssl rand -base64 32 | tr -d "/")
      sed -i.bak "s/REPLACE/$KEYSTOREPWD/g" $SNIPPETS_SOURCE/keystore.xml
      cp $SNIPPETS_SOURCE/keystore.xml $SNIPPETS_TARGET/keystore.xml
    fi
  fi
fi

# Pass on to the real server run
exec "$@"