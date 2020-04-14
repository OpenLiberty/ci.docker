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


# Infinispan Session Caching
if [ -n ${INFINISPAN_SERVICE_NAME} ]
then
 echo "INFINISPAN_SERVICE_NAME(original): ${INFINISPAN_SERVICE_NAME}"
 INFINISPAN_SERVICE_NAME=$(echo ${INFINISPAN_SERVICE_NAME} | sed 's/-/_/g' | sed 's/./\U&/g')
 echo "INFINISPAN_SERVICE_NAME(normalized): ${INFINISPAN_SERVICE_NAME}"

 if [ -z ${INFINISPAN_HOST} ]
 then
  eval INFINISPAN_HOST=\$${INFINISPAN_SERVICE_NAME}_SERVICE_HOST
  export INFINISPAN_HOST
 fi
 echo "INFINISPAN_HOST: ${INFINISPAN_HOST}"

 if [ -z ${INFINISPAN_PORT} ]
 then
  eval INFINISPAN_PORT=\$${INFINISPAN_SERVICE_NAME}_SERVICE_PORT
  export INFINISPAN_PORT
 fi
 echo "INFINISPAN_PORT: ${INFINISPAN_PORT:=11222}"

 if [ -z ${INFINISPAN_USER} ]
 then
  export INFINISPAN_USER=$(cat ${LIBERTY_INFINISPAN_SECRET_DIR:=/platform/bindings/secret}/identities.yaml | grep -m 1 username | sed 's/username://' | sed 's/[[:space:]]*//g' | sed 's/^-//')
 fi
 echo "INFINISPAN_USER: ${INFINISPAN_USER:=developer}"

 if [ -z ${INFINISPAN_PASS} ]
 then
  export INFINISPAN_PASS=$(cat ${LIBERTY_INFINISPAN_SECRET_DIR:=/platform/bindings/secret}/identities.yaml | grep -m 1 password | sed 's/password://' | sed 's/[[:space:]]*//g')
 fi
 echo "INFINISPAN_PASS: ${INFINISPAN_PASS}"
fi

# Pass on to the real server run
exec "$@"
