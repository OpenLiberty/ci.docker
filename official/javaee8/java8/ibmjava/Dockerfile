
FROM ibmjava:8-jre
ARG LIBERTY_VERSION=19.0.0.1
ARG LIBERTY_SHA=c0804d8e17f716134c2aec3e23280a0bb73fa450
ARG LIBERTY_DOWNLOAD_URL=https://repo1.maven.org/maven2/io/openliberty/openliberty-javaee8/$LIBERTY_VERSION/openliberty-javaee8-$LIBERTY_VERSION.zip

LABEL maintainer="Alasdair Nottingham" vendor="Open Liberty" url="https://openliberty.io/" github="https://github.com/OpenLiberty/ci.docker"

COPY docker-server /opt/ol/docker/

# Install Open Liberty
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/* \
    && wget -q $LIBERTY_DOWNLOAD_URL -U UA-Open-Liberty-Docker -O /tmp/wlp.zip \
    && echo "$LIBERTY_SHA  /tmp/wlp.zip" > /tmp/wlp.zip.sha1 \
    && sha1sum -c /tmp/wlp.zip.sha1 \
    && unzip -q /tmp/wlp.zip -d /opt/ol \
    && rm /tmp/wlp.zip \
    && rm /tmp/wlp.zip.sha1 \
    && apt-get remove -y unzip \
    && rm -rf /var/lib/apt/lists/* 

# Set Path Shortcuts
ENV PATH=/opt/ol/wlp/bin:/opt/ol/docker/:$PATH \
    LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ol/wlp/output \
    WLP_SKIP_MAXPERMSIZE=true \
    KEYSTORE_REQUIRED=true

RUN mkdir /logs \
    && mkdir -p $WLP_OUTPUT_DIR/defaultServer \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ol/wlp/usr/servers/defaultServer /config \
    && ln -s /logs $WLP_OUTPUT_DIR/defaultServer/logs \
    && ln -s /liberty /opt/ol/wlp

# Configure WebSphere Liberty
RUN /opt/ol/wlp/bin/server create \
    && rm /config/server.env \
    && rm -rf $WLP_OUTPUT_DIR/.classCache /output/workarea \
    && mkdir /config/configDropins \
    && mkdir /config/configDropins/defaults \
    && echo "<server description=\"Default Server\"><httpEndpoint id=\"defaultHttpEndpoint\" host=\"*\" /></server>" > /config/configDropins/defaults/open-default-port.xml \
    && /opt/ol/wlp/bin/server start && /opt/ol/wlp/bin/server stop && rm -rf /output/resources/security/ && rm -rf /output/messaging /logs/*

EXPOSE 9080 9443

ENTRYPOINT ["/opt/ol/docker/docker-server"]
CMD ["/opt/ol/wlp/bin/server", "run", "defaultServer"]
