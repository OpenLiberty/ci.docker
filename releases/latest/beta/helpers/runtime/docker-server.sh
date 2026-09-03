#!/bin/bash
function setPasswords() {
  local -n pass=$1
  local -n trustpass=$2
  if [ -z "$pass" ]; then
    pass=$(openssl rand -base64 32 2>/dev/null)
    trustpass=$(openssl rand -base64 32 2>/dev/null)
  fi
}

function updateTruststoreFromFile() {
  local TRUSTSTORE_FILE=$1
  local TRUSTSTORE_PASSWORD=$2
  local CERT_FILE=$3
  local ALIAS=$4

  keytool -import -storetype pkcs12 -noprompt -keystore "${TRUSTSTORE_FILE}" -file "${CERT_FILE}" \
    -storepass "${TRUSTSTORE_PASSWORD}" -alias "${ALIAS}" >&/dev/null
}

function updateTruststoreFromDir() {
  local TRUSTSTORE_CERT_DIR=$1
  local TRUSTSTORE_PASSWORD=$2
  local TRUSTSTORE_FILE=$3
  local ALIAS_PREFIX=$4

  local -r CRT_DELIMITER="/-----BEGIN CERTIFICATE-----/"
  local TMP_CERT_DIR=$(mktemp -d)
  local TMP_CERT="${TMP_CERT_DIR}/combined.crt"

  pushd "${TMP_CERT_DIR}" >&/dev/null
  cat "${TRUSTSTORE_CERT_DIR}"/*.crt >"${TMP_CERT}"
  # CA bundles need to be split and added as individual certificates
  csplit -s -z -f crt- "${TMP_CERT}" "${CRT_DELIMITER}" '{*}'
  for CERT_FILE in crt-*; do
    updateTruststoreFromFile "${TRUSTSTORE_FILE}" "${TRUSTSTORE_PASSWORD}" "${CERT_FILE}" "${ALIAS_PREFIX}-${CERT_FILE}"
  done
  popd >&/dev/null
  rm -rf "${TMP_CERT_DIR}"
}

function importKeyCert() {
  local CERT_FOLDER="${TLS_DIR:-/etc/x509/certs}"
  local CRT_FILE="tls.crt"
  local KEY_FILE="tls.key"
  local CA_FILE="ca.crt"
  local PASSWORD=
  local TRUSTSTORE_PASSWORD=
  local KUBE_SA_FOLDER="/var/run/secrets/kubernetes.io/serviceaccount"
  local KEYSTORE_FILE="/output/resources/security/key.p12"
  local TRUSTSTORE_FILE="/output/resources/security/trust.p12"

  # Import the private key and certificate into new keystore
  if [ -f "${CERT_FOLDER}/${KEY_FILE}" ] && [ -f "${CERT_FOLDER}/${CRT_FILE}" ]; then
    # Mounted certificates found. Assume the user wants to overwrite any existing keystore
    # and add these certificates
    echo "Found mounted TLS certificates, generating keystore"
    setPasswords PASSWORD TRUSTSTORE_PASSWORD
    mkdir -p /output/resources/security
    if [ -f "${CERT_FOLDER}/${CA_FILE}" ]; then
      openssl pkcs12 -export \
        -name "defaultKeyStore" \
        -inkey "${CERT_FOLDER}/${KEY_FILE}" \
        -in "${CERT_FOLDER}/${CRT_FILE}" \
        -certfile "${CERT_FOLDER}/${CA_FILE}" \
        -out "${KEYSTORE_FILE}" \
        -password pass:"${PASSWORD}" >&/dev/null
    else
      openssl pkcs12 -export \
        -name "defaultKeyStore" \
        -inkey "${CERT_FOLDER}/${KEY_FILE}" \
        -in "${CERT_FOLDER}/${CRT_FILE}" \
        -out "${KEYSTORE_FILE}" \
        -password pass:"${PASSWORD}" >&/dev/null
    fi

    # Since we are creating new keystore, always write new password to a file
    sed "s|REPLACE|$PASSWORD|g" $SNIPPETS_SOURCE/keystore.xml > $keystorePathOverride

    # Add mounted CA to the truststore
    if [ -f "${CERT_FOLDER}/${CA_FILE}" ]; then
      echo "Found mounted TLS CA certificate, adding to truststore"
      updateTruststoreFromFile "${TRUSTSTORE_FILE}" "${TRUSTSTORE_PASSWORD}" "${CERT_FOLDER}/${CA_FILE}" "service-ca"
    fi
  fi

  # Add kubernetes CA certificates to the truststore
  if [ "$SEC_IMPORT_K8S_CERTS" = "true" ] && [ -d "${KUBE_SA_FOLDER}" ]; then
    echo "Found mounted K8S CA certificates, adding to truststore"
    updateTruststoreFromDir "${KUBE_SA_FOLDER}" "${TRUSTSTORE_PASSWORD}" "${TRUSTSTORE_FILE}" "service-sa"
  fi

  # Add CA certificates from extra truststore directory
  if [ -d "${EXTRA_TRUSTSTORE_DIR}" ]; then
    echo "Found extra truststore directory, adding to truststore"
    updateTruststoreFromDir "${EXTRA_TRUSTSTORE_DIR}" "${TRUSTSTORE_PASSWORD}" "${TRUSTSTORE_FILE}" "extra-ca"
  fi

  # If no keystore has been created, add a keystore password to server configuration
  if [ ! -e "$keystorePathDefault" ] && [ ! -e "$keystorePathOverride" ]; then
    setPasswords PASSWORD TRUSTSTORE_PASSWORD
    sed "s|REPLACE|$PASSWORD|g" $SNIPPETS_SOURCE/keystore.xml > $keystorePathDefault
  fi
  if [ -e "$TRUSTSTORE_FILE" ]; then
    setPasswords PASSWORD TRUSTSTORE_PASSWORD
    sed "s|PWD_TRUST|$TRUSTSTORE_PASSWORD|g" $SNIPPETS_SOURCE/truststore.xml > $SNIPPETS_TARGET_OVERRIDES/truststore.xml
  elif [ ! -z "$SEC_TLS_TRUSTDEFAULTCERTS" ]; then
    cp $SNIPPETS_SOURCE/trustDefault.xml $SNIPPETS_TARGET_OVERRIDES/trustDefault.xml
  fi
}

set -e

SNIPPETS_SOURCE=/opt/ol/helpers/build/configuration_snippets
SNIPPETS_TARGET_DEFAULTS=/config/configDropins/defaults
SNIPPETS_TARGET_OVERRIDES=/config/configDropins/overrides

keystorePathDefault="$SNIPPETS_TARGET_DEFAULTS/keystore.xml"
keystorePathOverride="$SNIPPETS_TARGET_OVERRIDES/keystore.xml"

if [ "$SSL" = "true" ] || [ "$TLS" = "true" ]; then
  cp $SNIPPETS_SOURCE/tls.xml $SNIPPETS_TARGET_OVERRIDES/tls.xml
fi

importKeyCert


if [ "${GENERATE_LTPA_KEYS_PASSWORD:-true}" = "true" ] && [ -z "$ltpa_keys_password" ]; then
  export ltpa_keys_password=$(openssl rand -base64 32 2>/dev/null)
  if [ "$VERBOSE" == "true" ]; then
    echo "Generated ltpa_keys_password for LTPA configuration"
  fi
fi

# Infinispan Session Caching
if [[ -n "$INFINISPAN_SERVICE_NAME" ]]; then
 echo "INFINISPAN_SERVICE_NAME(original): ${INFINISPAN_SERVICE_NAME}"
 INFINISPAN_SERVICE_NAME=$(echo ${INFINISPAN_SERVICE_NAME} | sed 's/-/_/g' | sed 's/./\U&/g')
 echo "INFINISPAN_SERVICE_NAME(normalized): ${INFINISPAN_SERVICE_NAME}"

 if [[ -z "$INFINISPAN_HOST" ]]; then
  eval INFINISPAN_HOST=\$${INFINISPAN_SERVICE_NAME}_SERVICE_HOST
  export INFINISPAN_HOST
 fi
 echo "INFINISPAN_HOST: ${INFINISPAN_HOST}"

 if [[ -z "$INFINISPAN_PORT" ]]; then
  eval INFINISPAN_PORT=\$${INFINISPAN_SERVICE_NAME}_SERVICE_PORT
  export INFINISPAN_PORT
 fi
 echo "INFINISPAN_PORT: ${INFINISPAN_PORT:=11222}"

 if [[ -z "$INFINISPAN_USER" ]]; then
  export INFINISPAN_USER=$(cat ${LIBERTY_INFINISPAN_SECRET_DIR:=/platform/bindings/infinispan/secret}/identities.yaml | grep -m 1 username | sed 's/username://' | sed 's/[[:space:]]*//g' | sed 's/^-//')
 fi
 echo "INFINISPAN_USER: ${INFINISPAN_USER:=developer}"

 if [[ -z "$INFINISPAN_PASS" ]]; then
  export INFINISPAN_PASS=$(cat ${LIBERTY_INFINISPAN_SECRET_DIR:=/platform/bindings/infinispan/secret}/identities.yaml | grep -m 1 password | sed 's/password://' | sed 's/[[:space:]]*//g')
 fi
 echo "INFINISPAN_PASS: ${INFINISPAN_PASS}"
fi

# If SERVICEABILITY_NAMESPACE is set, link /liberty/logs to the serviceability directory
if [[ ! -z "$SERVICEABILITY_NAMESPACE" ]] && [[ ! -z $HOSTNAME ]]; then
  SERVICEABILITY_FOLDER="/serviceability/$SERVICEABILITY_NAMESPACE/$HOSTNAME/logs"
  mkdir -p $SERVICEABILITY_FOLDER
  rm /liberty/logs
  ln -s $SERVICEABILITY_FOLDER /liberty/logs
fi

# Pass on to the real server run
if [ -d "/output/workarea/checkpoint/image" ]; then
  # A checkpoint image found; exec dumb-init for signal handling.
  # Use of dumb-init for PID 1 is required for signal handling because
  # the restored server process cannot be PID 1.
  exec dumb-init --rewrite 15:2 -- /opt/ol/helpers/runtime/restore-server.sh "$@"
elif [[ ! -z "$WLP_CHECKPOINT" ]]; then
  # Unset WLP_CHECKPOINT so it is not set in the final image after checkpoint.
  TMP_CHECKPOINT=$WLP_CHECKPOINT
  unset WLP_CHECKPOINT
  # A checkpoint action has been requested; run the checkpoint.sh script.
  checkpoint.sh "$TMP_CHECKPOINT"
else
  # The default is to just exec the supplied CMD
  exec "$@"
fi
