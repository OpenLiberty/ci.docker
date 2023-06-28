ARG IMAGE=openliberty/open-liberty:kernel-slim-java8-openj9-ubi

FROM alpine as staging

# Generate random certificates
RUN apk add openssl
RUN openssl req -new -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out tls.crt -keyout tls.key -subj "/OU=defaultServer/CN=ci.docker.test"
RUN cp tls.crt ca.crt

FROM ${IMAGE}

COPY --chown=1001:0 server.xml /config/
# Add certificates to TLS_DIR
COPY --from=staging --chown=1001:0 tls.crt /etc/x509/certs/
COPY --from=staging --chown=1001:0 tls.key /etc/x509/certs/
COPY --from=staging --chown=1001:0 ca.crt /etc/x509/certs/

# This script will add the requested XML snippets to enable Liberty features and grow image to be fit-for-purpose using featureUtility
RUN features.sh

# This script will add the requested server configurations, apply any iFixes and populate caches to optimize runtime
RUN configure.sh