#!/bin/bash
if [ "$VERBOSE" != "true" ]; then
  exec &>/dev/null
fi

set -Eeox pipefail

##Define variables for XML snippets source and target paths
WLP_INSTALL_DIR=/opt/ol/wlp
SHARED_CONFIG_DIR=${WLP_INSTALL_DIR}/usr/shared/config
SHARED_RESOURCE_DIR=${WLP_INSTALL_DIR}/usr/shared/resources

SNIPPETS_SOURCE=/opt/ol/helpers/build/configuration_snippets
SNIPPETS_TARGET=/config/configDropins/overrides
SNIPPETS_TARGET_DEFAULTS=/config/configDropins/defaults
mkdir -p ${SNIPPETS_TARGET}


#Check for each Liberty value-add functionality

# MicroProfile Health
if [ "$MP_HEALTH_CHECK" == "true" ]; then
  cp $SNIPPETS_SOURCE/mp-health-check.xml $SNIPPETS_TARGET/mp-health-check.xml
fi

# MicroProfile Monitoring
if [ "$MP_MONITORING" == "true" ]; then
  cp $SNIPPETS_SOURCE/mp-monitoring.xml $SNIPPETS_TARGET/mp-monitoring.xml
fi

# HTTP Endpoint
if [ "$HTTP_ENDPOINT" == "true" ]; then
  if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]; then
    cp $SNIPPETS_SOURCE/http-ssl-endpoint.xml $SNIPPETS_TARGET/http-ssl-endpoint.xml
  else
    cp $SNIPPETS_SOURCE/http-endpoint.xml $SNIPPETS_TARGET/http-endpoint.xml
  fi
fi

# Hazelcast Session Caching
if [ "${HZ_SESSION_CACHE}" == "client" ] || [ "${HZ_SESSION_CACHE}" == "embedded" ]
then
 cp ${SNIPPETS_SOURCE}/hazelcast-sessioncache.xml ${SNIPPETS_TARGET}/hazelcast-sessioncache.xml
 mkdir -p ${SHARED_CONFIG_DIR}/hazelcast
 cp ${SNIPPETS_SOURCE}/hazelcast-${HZ_SESSION_CACHE}.xml ${SHARED_CONFIG_DIR}/hazelcast/hazelcast.xml
fi

# IIOP Endpoint
if [ "$IIOP_ENDPOINT" == "true" ]; then
  if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]; then
    cp $SNIPPETS_SOURCE/iiop-ssl-endpoint.xml $SNIPPETS_TARGET/iiop-ssl-endpoint.xml
  else
    cp $SNIPPETS_SOURCE/iiop-endpoint.xml $SNIPPETS_TARGET/iiop-endpoint.xml
  fi
fi

# JMS Endpoint
if [ "$JMS_ENDPOINT" == "true" ]; then
  if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]; then
    cp $SNIPPETS_SOURCE/jms-ssl-endpoint.xml $SNIPPETS_TARGET/jms-ssl-endpoint.xml
  else
    cp $SNIPPETS_SOURCE/jms-endpoint.xml $SNIPPETS_TARGET/jms-endpoint.xml
  fi
fi

# Key Store
keystorePath="$SNIPPETS_TARGET_DEFAULTS/keystore.xml"
if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]
then
  cp $SNIPPETS_SOURCE/tls.xml $SNIPPETS_TARGET/tls.xml
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

# Apply interim fixes found in /opt/ol/fixes
# Fixes recommended by IBM, such as to resolve security vulnerabilities, are also included in /opt/ol/fixes
# Note: This step should be done once needed features are enabled and installed.
find /opt/ol/fixes -type f -name "*.jar"  -print0 | sort -z | xargs -0 -n 1 -r -I {} java -jar {} --installLocation $WLP_INSTALL_DIR

# Server start/stop to populate the /output/workarea and make subsequent server starts faster
/opt/ol/wlp/bin/server start && /opt/ol/wlp/bin/server stop && rm -rf /output/messaging /logs/* $WLP_OUTPUT_DIR/.classCache && chmod -R g+rwx /opt/ol/wlp/output/*
