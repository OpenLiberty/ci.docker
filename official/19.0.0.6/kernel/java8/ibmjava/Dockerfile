FROM ibmjava:8-jre
ARG LIBERTY_VERSION=19.0.0.6
ARG LIBERTY_SHA=4e97ebc8a94c75dead89282c04f78cac3c8e0ba4
ARG LIBERTY_BUILD_LABEL=cl190620190617-1530
ARG LIBERTY_DOWNLOAD_URL=https://repo1.maven.org/maven2/io/openliberty/openliberty-runtime/$LIBERTY_VERSION/openliberty-runtime-$LIBERTY_VERSION.zip

LABEL org.opencontainers.image.authors="Arthur De Magalhaes, Chris Potter" \
      org.opencontainers.image.vendor="Open Liberty" \
      org.opencontainers.image.url="https://openliberty.io/" \
      org.opencontainers.image.source="https://github.com/OpenLiberty/ci.docker" \
      org.opencontainers.image.revision="$LIBERTY_BUILD_LABEL"

COPY helpers /opt/ol/helpers

# Install Open Liberty
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip openssl \
    && rm -rf /var/lib/apt/lists/* \
    && wget -q $LIBERTY_DOWNLOAD_URL -U UA-Open-Liberty-Docker -O /tmp/wlp.zip \
    && echo "$LIBERTY_SHA  /tmp/wlp.zip" > /tmp/wlp.zip.sha1 \
    && sha1sum -c /tmp/wlp.zip.sha1 \
    && unzip -q /tmp/wlp.zip -d /opt/ol \
    && rm /tmp/wlp.zip \
    && rm /tmp/wlp.zip.sha1 \
    && apt-get remove -y unzip \
    && apt-get remove -y wget \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -u 1001 -r -g 0 -s /usr/sbin/nologin default \
    && chown -R 1001:0 /opt/ol/wlp \
    && chmod -R g+rw /opt/ol/wlp

# Set Path Shortcuts
ENV PATH=/opt/ol/wlp/bin:/opt/ol/docker/:/opt/ol/helpers/build:$PATH \
    LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ol/wlp/output \
    WLP_SKIP_MAXPERMSIZE=true

# Configure Open Liberty
RUN /opt/ol/wlp/bin/server create \
    && rm -rf $WLP_OUTPUT_DIR/.classCache /output/workarea


# Create symlinks && set permissions for non-root user    
RUN mkdir /logs \
    && mkdir -p /opt/ol/wlp/usr/shared/resources/lib.index.cache \
    && ln -s /opt/ol/wlp/usr/shared/resources/lib.index.cache /lib.index.cache \
    && mkdir -p $WLP_OUTPUT_DIR/defaultServer \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ol/wlp/usr/servers/defaultServer /config \
    && mkdir -p /config/configDropins/defaults \
    && mkdir -p /config/configDropins/overrides \
    && ln -s /opt/ol/wlp /liberty \
    && chown -R 1001:0 /config \
    && chmod -R g+rw /config \
    && chown -R 1001:0 /logs \
    && chmod -R g+rw /logs \
    && chown -R 1001:0 /opt/ol/wlp/usr \
    && chmod -R g+rw /opt/ol/wlp/usr \
    && chown -R 1001:0 /opt/ol/wlp/output \
    && chmod -R g+rw /opt/ol/wlp/output \
    && chown -R 1001:0 /opt/ol/helpers \
    && chmod -R g+rw /opt/ol/helpers \
    && mkdir /etc/wlp \
    && chown -R 1001:0 /etc/wlp \
    && chmod -R g+rw /etc/wlp \
    && echo "<server description=\"Default Server\"><httpEndpoint id=\"defaultHttpEndpoint\" host=\"*\" /></server>" > /config/configDropins/defaults/open-default-port.xml


#These settings are needed so that we can run as a different user than 1001 after server warmup
ENV RANDFILE=/tmp/.rnd \
    IBM_JAVA_OPTIONS="-Xshareclasses:name=liberty,nonfatal,cacheDir=/output/.classCache/ ${IBM_JAVA_OPTIONS}"

USER 1001

EXPOSE 9080 9443

ENTRYPOINT ["/opt/ol/helpers/runtime/docker-server.sh"]
CMD ["/opt/ol/wlp/bin/server", "run", "defaultServer"]
