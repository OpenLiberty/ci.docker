
FROM ibmjava:8-jre

LABEL maintainer="Alasdair Nottingham" vendor="Open Liberty" url="https://openliberty.io/" github="https://github.com/OpenLiberty/ci.docker"

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Open Liberty
ENV LIBERTY_VERSION=17.0.0.4 \
    LIBERTY_SHA=8709c75cf905051e043b8c63e25640b464e58e39

RUN wget https://repo1.maven.org/maven2/io/openliberty/openliberty-runtime/$LIBERTY_VERSION/openliberty-runtime-$LIBERTY_VERSION.zip -U UA-Open-Liberty-Docker -O /tmp/wlp.zip \
   && echo "$LIBERTY_SHA  /tmp/wlp.zip" > /tmp/wlp.zip.sha1 \
   && sha1sum -c /tmp/wlp.zip.sha1 \
   && unzip -q /tmp/wlp.zip -d /opt/ol \
   && rm /tmp/wlp.zip \
   && rm /tmp/wlp.zip.sha1

# Set Path Shortcuts
ENV PATH=/opt/ol/wlp/bin:/opt/ol/docker/:$PATH \
    LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ol/wlp/output
RUN mkdir /logs \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ol/wlp/usr/servers/defaultServer /config

# Configure WebSphere Liberty
RUN /opt/ol/wlp/bin/server create \
    && rm -rf $WLP_OUTPUT_DIR/.classCache /output/workarea \
    && mkdir /config/configDropins \
    && mkdir /config/configDropins/defaults \
    && echo "<server description=\"Default Server\"><httpEndpoint id=\"defaultHttpEndpoint\" host=\"*\" /></server>" > /config/configDropins/defaults/open-default-port.xml

COPY docker-server /opt/ol/docker/

EXPOSE 9080 9443

ENTRYPOINT ["/opt/ol/docker/docker-server"]
CMD ["/opt/ol/wlp/bin/server", "run", "defaultServer"]
