
FROM ibmjava:8-sfj-alpine
ARG LIBERTY_VERSION=19.0.0.2
ARG LIBERTY_SHA=d4eab6bcd7666bceb0fd3d3f736b98868f3c9d09
ARG LIBERTY_DOWNLOAD_URL=https://repo1.maven.org/maven2/io/openliberty/openliberty-webProfile8/$LIBERTY_VERSION/openliberty-webProfile8-$LIBERTY_VERSION.zip

COPY docker-server /opt/ol/docker/

# Install Open Liberty
RUN apk add --no-cache wget \
   && wget -q $LIBERTY_DOWNLOAD_URL -U UA-Open-Liberty-Docker -O /tmp/wlp.zip \
   && echo "$LIBERTY_SHA  /tmp/wlp.zip" > /tmp/wlp.zip.sha1 \
   && sha1sum -c /tmp/wlp.zip.sha1 \
   && unzip -q /tmp/wlp.zip -d /opt/ol \
   && rm /tmp/wlp.zip \
   && rm /tmp/wlp.zip.sha1

# Set Path Shortcuts
ENV PATH=/opt/ol/wlp/bin:/opt/ol/docker/:$PATH \
    LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ol/wlp/output \
    WLP_SKIP_MAXPERMSIZE=true

RUN mkdir /logs \
    && mkdir -p $WLP_OUTPUT_DIR/defaultServer \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ol/wlp/usr/servers/defaultServer /config \
    && ln -s /logs $WLP_OUTPUT_DIR/defaultServer/logs

# Configure WebSphere Liberty
RUN /opt/ol/wlp/bin/server create \
    && rm /config/server.env \
    && rm -rf $WLP_OUTPUT_DIR/.classCache /output/workarea \
    && mkdir /config/configDropins \
    && mkdir /config/configDropins/defaults \
    && echo "<server description=\"Default Server\"><httpEndpoint id=\"defaultHttpEndpoint\" host=\"*\" /></server>" > /config/configDropins/defaults/open-default-port.xml \
    && /opt/ol/wlp/bin/server start && /opt/ol/wlp/bin/server stop && rm -rf /output/resources/security/ /logs/*


EXPOSE 9080 9443

ENTRYPOINT ["/opt/ol/docker/docker-server"]
CMD ["/opt/ol/wlp/bin/server", "run", "defaultServer"]
