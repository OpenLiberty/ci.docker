ARG IMAGE=openliberty/open-liberty:kernel-slim-java8-openj9-ubi

FROM alpine as staging

# Generate certificates (for test only)
RUN apk add openssl
RUN openssl req -new -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out tls.crt -keyout tls.key -subj "/C=CA/ST=Ontario/L=Markham/O=IBM/OU=WAS/CN=ci.docker.test"

FROM ${IMAGE}

COPY --chown=1001:0 server.xml /config/
# Add certificates to TLS_DIR
ENV TLS_DIR=/config/certs
RUN mkdir -p /config/certs
COPY --from=staging --chown=1001:0 tls.crt /config/certs/
COPY --from=staging --chown=1001:0 tls.key /config/certs/
COPY --from=staging --chown=1001:0 tls.crt /config/certs/ca.crt

# Add rw perms for non-default user
RUN setfacl -R -Lm g:root:rw /config/certs

# This script will add the requested XML snippets to enable Liberty features and grow image to be fit-for-purpose using featureUtility
RUN features.sh

# This script will add the requested server configurations, apply any iFixes and populate caches to optimize runtime
RUN configure.sh