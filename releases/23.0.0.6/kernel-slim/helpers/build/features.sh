#!/bin/bash

if [ "$VERBOSE" != "true" ]; then
  exec &>/dev/null
fi

set -Eeox pipefail

##Define variables for XML snippets source and target paths
SNIPPETS_SOURCE=/opt/ol/helpers/build/configuration_snippets
SNIPPETS_TARGET=/config/configDropins/overrides
SNIPPETS_TARGET_DEFAULTS=/config/configDropins/defaults
mkdir -p ${SNIPPETS_TARGET}
mkdir -p ${SNIPPETS_TARGET_DEFAULTS}

# Session Caching
if [ -n "$INFINISPAN_SERVICE_NAME" ] || [ "${HZ_SESSION_CACHE}" == "client" ] || [ "${HZ_SESSION_CACHE}" == "embedded" ]; then
  cp ${SNIPPETS_SOURCE}/sessioncache-features.xml ${SNIPPETS_TARGET}/sessioncache-features.xml
  chmod g+rw $SNIPPETS_TARGET/sessioncache-features.xml
fi

# SSO
if [[ -n "$SEC_SSO_PROVIDERS" ]]; then
  cp $SNIPPETS_SOURCE/sso-features.xml $SNIPPETS_TARGET_DEFAULTS
fi

# Key Store
if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]; then
  cp $SNIPPETS_SOURCE/tls.xml $SNIPPETS_TARGET/tls.xml
fi

# Install necessary features using featureUtility
featureUtility installServerFeatures --acceptLicense defaultServer --noCache
find /opt/ol/wlp/lib /opt/ol/wlp/bin ! -perm -g=rw -print0 | xargs -0 -r chmod g+rw

