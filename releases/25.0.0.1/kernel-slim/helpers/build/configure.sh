#!/bin/bash

. /opt/ol/helpers/build/internal/logger.sh

set -Eeox pipefail

function main() {
  ##Define variables for XML snippets source and target paths
  WLP_INSTALL_DIR=/opt/ol/wlp
  SHARED_CONFIG_DIR=${WLP_INSTALL_DIR}/usr/shared/config
  SHARED_RESOURCE_DIR=${WLP_INSTALL_DIR}/usr/shared/resources

  SNIPPETS_SOURCE=/opt/ol/helpers/build/configuration_snippets
  SNIPPETS_TARGET=/config/configDropins/overrides
  SNIPPETS_TARGET_DEFAULTS=/config/configDropins/defaults
  mkdir -p ${SNIPPETS_TARGET}
  mkdir -p ${SNIPPETS_TARGET_DEFAULTS}

  #Check for each Liberty value-add functionality

  # Infinispan Session Caching
  if [[ -n "$INFINISPAN_SERVICE_NAME" ]]; then
   cp ${SNIPPETS_SOURCE}/infinispan-client-sessioncache.xml ${SNIPPETS_TARGET}/infinispan-client-sessioncache.xml
   chmod g+rw $SNIPPETS_TARGET/infinispan-client-sessioncache.xml
  fi

  # Hazelcast Session Caching
  if [ "${HZ_SESSION_CACHE}" == "client" ] || [ "${HZ_SESSION_CACHE}" == "embedded" ]; then
    cp ${SNIPPETS_SOURCE}/hazelcast-sessioncache.xml ${SNIPPETS_TARGET}/hazelcast-sessioncache.xml
    mkdir -p ${SHARED_CONFIG_DIR}/hazelcast
    cp ${SNIPPETS_SOURCE}/hazelcast-${HZ_SESSION_CACHE}.xml ${SHARED_CONFIG_DIR}/hazelcast/hazelcast.xml
  fi

  # Key Store
  keystorePath="$SNIPPETS_TARGET_DEFAULTS/keystore.xml"
  if [ "$SSL" != "false" ] && [ "$TLS" != "false" ]; then
    if [ ! -e $keystorePath ]; then
      # Generate the keystore.xml
      hideLogs
      KEYSTOREPWD=$(openssl rand -base64 32)
      sed "s|REPLACE|$KEYSTOREPWD|g" $SNIPPETS_SOURCE/keystore.xml >$SNIPPETS_TARGET_DEFAULTS/keystore.xml
      showLogs
      chmod g+w $SNIPPETS_TARGET_DEFAULTS/keystore.xml
    fi
  fi

  # SSO
  if [[ -n "$SEC_SSO_PROVIDERS" ]]; then
    parseProviders $SEC_SSO_PROVIDERS
  fi

  # Apply interim fixes found in /opt/ol/fixes
  # Fixes recommended by IBM, such as to resolve security vulnerabilities, are also included in /opt/ol/fixes
  # Note: This step should only be done ONCE needed features are enabled and installed.
  find /opt/ol/fixes -type f -name "*.jar"  -print0 | sort -z | xargs -0 -n 1 -r -I {} java -jar {} --installLocation $WLP_INSTALL_DIR

  # Force the server.xml to be processed by updating its timestamp
  touch /config/server.xml

  # Create a new SCC layer. This should be invoked when server configuration is complete.
  if [ "$OPENJ9_SCC" == "true" ]; then
    cmd="populate_scc.sh -i 1"
    if [ "$TRIM_SCC" == "false" ]; then
      cmd+=" -d"
    fi
    if [ ! "$SCC_SIZE" = "" ]; then
      cmd+=" -s $SCC_SIZE"
    fi
    if [ "$WARM_ENDPOINT" = "false" ]; then
      cmd+=" -c"
    fi
    if [ ! "$WARM_ENDPOINT_URL" = "" ]; then
      cmd+=" -u $WARM_ENDPOINT_URL"
    fi
    if [ "$WARM_OPENAPI_ENDPOINT" = "false" ]; then
      cmd+=" -l"
    fi
    if [ ! "$WARM_OPENAPI_ENDPOINT_URL" = "" ]; then
      cmd+=" -o $WARM_OPENAPI_ENDPOINT_URL"
    fi
    eval $cmd
  fi
}

## parse provider list to generate files into configDropins
function parseProviders() {
  while [ $# -gt 0 ]; do
    case "$1" in
    oidc:*)
      parseCommaList oidc "${1#*:}"
      ;;
    oauth2:*)
      parseCommaList oauth2 "${1#*:}"
      ;;
    *)
      if [[ $(ls $SNIPPETS_SOURCE | grep "$1") ]]; then
        cp $SNIPPETS_SOURCE/sso-${1}.xml $SNIPPETS_TARGET_DEFAULTS
      fi
      ;;
    esac
    shift
  done
}

## process the comma delimitted oauth2/oidc source lists
function parseCommaList() {
  local type="$1"
  local list=$(echo "$2" | tr , " ")

  for current in ${list}; do
    if [[ "${type}" = "oidc" ]]; then
      # replace oidc identifiers with custom name
      sed -e 's/=\"oidc/=\"'${current}'/g' -e 's/_OIDC_/_'${current^^}'_/g' $SNIPPETS_SOURCE/sso-oidc.xml > $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml
    else
      # replace oauth2 identifiers with custom name
      sed -e 's/=\"oauth2/=\"'${current}'/g' -e 's/_OAUTH2_/_'${current^^}'_/g' $SNIPPETS_SOURCE/sso-oauth2.xml > $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml
    fi
  done
}

main "$@"
