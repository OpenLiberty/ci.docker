#!/bin/bash

if [ "$VERBOSE" != "true" ]; then
  exec &>/dev/null
fi

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
  if [ "${HZ_SESSION_CACHE}" == "client" ] || [ "${HZ_SESSION_CACHE}" == "embedded" ]; then
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
  if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]; then
    cp $SNIPPETS_SOURCE/tls.xml $SNIPPETS_TARGET/tls.xml
  fi

  if [ "$SSL" != "false" ] && [ "$TLS" != "false" ]; then
    if [ ! -e $keystorePath ]; then
      # Generate the keystore.xml
      export KEYSTOREPWD=$(openssl rand -base64 32)
      sed "s|REPLACE|$KEYSTOREPWD|g" $SNIPPETS_SOURCE/keystore.xml >$SNIPPETS_TARGET_DEFAULTS/keystore.xml
      chmod g+w $SNIPPETS_TARGET_DEFAULTS/keystore.xml
    fi
  fi

  if [[ -n "$SEC_SSO_PROVIDERS" ]]; then
    cp $SNIPPETS_SOURCE/sso-features.xml $SNIPPETS_TARGET_DEFAULTS
    parseProviders $SEC_SSO_PROVIDERS
  fi

  # Create a new SCC layer
  if [ "$OPENJ9_SCC" == "true" ]; then
    populate_scc.sh
  fi
}

## parse provider list to generate files into configDropins
function parseProviders() {
  while [ $# -gt 0 ]; do
    case "$1" in
    oidc:*)
      parseSourceList oidc "${1#*:}"
      ;;
    oauth2:*)
      parseSourceList oauth2 "${1#*:}"
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
function parseSourceList() {
  local type="$1"
  local list=$(echo "$2" | tr , " ")

  for current in ${list}; do
    if [[ "${type}" = "oidc" ]]; then
      cp $SNIPPETS_SOURCE/sso-oidc.xml $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml
      # replace id and login id
      sed -i.bak -e 's/=\"oidc/=\"'${current}'/g' $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml
      sed -i.bak -e 's/_OIDC_/_'$(toUpper ${current})'_/g' $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml
      rm $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml.bak
    else
      cp $SNIPPETS_SOURCE/sso-oauth2.xml $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml
      # replace id and login id
      sed -i.bak -e 's/=\"oauth2/=\"'${current}'/g' $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml
      sed -i.bak -e 's/_OAUTH2_/_'$(toUpper ${current})'_/g' $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml
      rm $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml.bak
    fi
  done
}

function toUpper() {
  echo $(printf '%s\n' "$1" | awk '{ print toupper($0) }')
}

main $@