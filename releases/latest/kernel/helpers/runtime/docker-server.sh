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
    export KEYSTOREPWD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')
    sed -i.bak "s|REPLACE|$KEYSTOREPWD|g" $SNIPPETS_SOURCE/keystore.xml
    cp $SNIPPETS_SOURCE/keystore.xml $SNIPPETS_TARGET_DEFAULTS/keystore.xml
  fi
fi

if [[ -n "$SSO_PROVIDERS" ]]; then
	if [[ $SSO_PROVIDERS == *"oidc"* ]]; then
		cp $SNIPPETS_SOURCE/sso-oidc.xml $SNIPPETS_TARGET_OVERRIDES
    fi
	if [[ $SSO_PROVIDERS == *"oauth"* ]]; then
		cp $SNIPPETS_SOURCE/sso-oauth.xml $SNIPPETS_TARGET_OVERRIDES
    fi
	if [[ $SSO_PROVIDERS == *"facebook"* ]]; then
		cp $SNIPPETS_SOURCE/sso-facebook.xml $SNIPPETS_TARGET_OVERRIDES
    fi
	if [[ $SSO_PROVIDERS == *"twitter"* ]]; then
		cp $SNIPPETS_SOURCE/sso-twitter.xml $SNIPPETS_TARGET_OVERRIDES
    fi    
	if [[ $SSO_PROVIDERS == *"linkedin"* ]]; then
		cp $SNIPPETS_SOURCE/sso-linkedin.xml $SNIPPETS_TARGET_OVERRIDES
    fi
	if [[ $SSO_PROVIDERS == *"google"* ]]; then
		cp $SNIPPETS_SOURCE/sso-google.xml $SNIPPETS_TARGET_OVERRIDES
    fi
	if [[ $SSO_PROVIDERS == *"github"* ]]; then
		cp $SNIPPETS_SOURCE/sso-github.xml $SNIPPETS_TARGET_OVERRIDES
    fi
fi       

# Pass on to the real server run
exec "$@"
