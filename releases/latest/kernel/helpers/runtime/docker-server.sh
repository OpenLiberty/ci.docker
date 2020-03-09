#!/bin/bash

function importKeyCert() {
  local CERT_FOLDER="${TLS_DIR:-/etc/x509/certs}"
  local CRT_FILE="tls.crt"
  local KEY_FILE="tls.key"
  local CA_FILE="ca.crt"
  local PASSWORD=$(openssl rand -base64 32 2>/dev/null)
  local TRUSTSTORE_PASSWORD=$(openssl rand -base64 32 2>/dev/null)
  local TMP_CERT=ca-bundle-temp.crt
  local -r CRT_DELIMITER="/-----BEGIN CERTIFICATE-----/"
  local KUBE_SA_FOLDER="/var/run/secrets/kubernetes.io/serviceaccount"
  local KEYSTORE_FILE="/output/resources/security/key.p12"
  local TRUSTSTORE_FILE="/output/resources/security/trust.p12"

  # Import the private key and certificate into new keytore
  if [ -f "${CERT_FOLDER}/${KEY_FILE}" ] && [ -f "${CERT_FOLDER}/${CRT_FILE}" ]; then
    echo "Found mounted TLS certificates, generating keystore"
    mkdir -p /output/resources/security
    openssl pkcs12 -export \
      -name "defaultKeyStore" \
      -inkey "${CERT_FOLDER}/${KEY_FILE}" \
      -in "${CERT_FOLDER}/${CRT_FILE}" \
      -out "${KEYSTORE_FILE}" \
      -password pass:"${PASSWORD}" >&/dev/null


    # Add mounted CA to the truststore
    if [ -f "${CERT_FOLDER}/${CA_FILE}" ]; then
        echo "Found mounted TLS CA certificate, adding to truststore"
        keytool -import -storetype pkcs12 -noprompt -keystore "${TRUSTSTORE_FILE}" -file "${CERT_FOLDER}/${CA_FILE}" \
          -storepass "${TRUSTSTORE_PASSWORD}" -alias "service-ca" >&/dev/null    
    fi
  fi

  # Add kubernetes CA certificates to the truststore
  # CA bundles need to be split and added as individual certificates
  if [ "$IMPORT_K8S_CERTS" = "true" ] && [ -d "${KUBE_SA_FOLDER}" ]; then
    mkdir /tmp/certs
    pushd /tmp/certs >&/dev/null
    cat ${KUBE_SA_FOLDER}/*.crt >${TMP_CERT}
    csplit -s -z -f crt- "${TMP_CERT}" "${CRT_DELIMITER}" '{*}'
    for CERT_FILE in crt-*; do
      keytool -import -storetype pkcs12 -noprompt -keystore "${TRUSTSTORE_FILE}" -file "${CERT_FILE}" \
        -storepass "${TRUSTSTORE_PASSWORD}" -alias "service-sa-${CERT_FILE}" >&/dev/null
    done
    popd >&/dev/null
    rm -rf /tmp/certs
  fi

  # Add the keystore password to server configuration
  if [ ! -e $keystorePath ]; then
    sed -i.bak "s|REPLACE|$PASSWORD|g" $SNIPPETS_SOURCE/keystore.xml
    cp $SNIPPETS_SOURCE/keystore.xml $SNIPPETS_TARGET_DEFAULTS/keystore.xml
  fi
  if [ -e $TRUSTSTORE_FILE ]; then
    sed -i.bak "s|PWD_TRUST|$TRUSTSTORE_PASSWORD|g" $SNIPPETS_SOURCE/truststore.xml
    cp $SNIPPETS_SOURCE/truststore.xml $SNIPPETS_TARGET_OVERRIDES/truststore.xml
  else
    cp $SNIPPETS_SOURCE/trustDefault.xml $SNIPPETS_TARGET_OVERRIDES/trustDefault.xml  
  fi
}

set -e

SNIPPETS_SOURCE=/opt/ol/helpers/build/configuration_snippets
SNIPPETS_TARGET_DEFAULTS=/config/configDropins/defaults
SNIPPETS_TARGET_OVERRIDES=/config/configDropins/overrides

keystorePath="$SNIPPETS_TARGET_DEFAULTS/keystore.xml"

if [ "$SSL" = "true" ] || [ "$TLS" = "true" ]; then
  cp $SNIPPETS_SOURCE/tls.xml $SNIPPETS_TARGET_OVERRIDES/tls.xml
fi

importKeyCert


# Pass on to the real server run
exec "$@"
