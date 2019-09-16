#!/bin/sh

set -e

SNIPPETS_SOURCE=/opt/ol/helpers/build/configuration_snippets
SNIPPETS_TARGET_DEFAULTS=/config/configDropins/defaults
SNIPPETS_TARGET_OVERRIDES=/config/configDropins/overrides

keystorePath="$SNIPPETS_TARGET_DEFAULTS/keystore.xml"

if [ "$SSL" = "true" ] || [ "$TLS" = "true" ]
then
  cp $SNIPPETS_SOURCE/tls.xml $SNIPPETS_TARGET_OVERRIDES/tls.xml
fi

if [ "$SSL" != "false" ] && [ "$TLS" != "false" ]
then
  if [ ! -e $keystorePath ]
  then
    # Generate the keystore.xml
    export KEYSTOREPWD=$(openssl rand -base64 32)
    sed -i.bak "s|REPLACE|$KEYSTOREPWD|g" $SNIPPETS_SOURCE/keystore.xml
    cp $SNIPPETS_SOURCE/keystore.xml $SNIPPETS_TARGET_DEFAULTS/keystore.xml
  fi
fi


# Pass on to the real server run
exec "$@"
