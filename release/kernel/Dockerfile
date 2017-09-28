
FROM ibmjava:8-jre

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Open Liberty
ENV LIBERTY_VERSION 17.0.0.3-RC
ENV LIBERTY_SHA 58e09e9dad2ca0b3133e25cf3bfee22003da115f

RUN wget https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/wasliberty-open-liberty/io/openliberty/openliberty-runtime/$LIBERTY_VERSION/openliberty-runtime-$LIBERTY_VERSION.zip -U UA-Open-Liberty-Docker -O /tmp/wlp.zip \
   && echo "$LIBERTY_SHA  /tmp/wlp.zip" > /tmp/wlp.zip.sha1 \
   && sha1sum -c /tmp/wlp.zip.sha1 \
   && unzip -q /tmp/wlp.zip -d /opt/ol \
   && rm /tmp/wlp.zip \
   && rm /tmp/wlp.zip.sha1

ENV PATH=/opt/ol/wlp/bin:$PATH

# Set Path Shortcuts
ENV LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ol/wlp/output
RUN mkdir /logs \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ol/wlp/usr/servers/defaultServer /config

ENV DEPLOYMENT_DIR /config/dropins/

# Configure Open Liberty
RUN /opt/ol/wlp/bin/server create \
    && rm -rf $WLP_OUTPUT_DIR/.classCache /output/workarea
COPY docker-server /opt/ol/docker/

EXPOSE 9080 9443

CMD ["/opt/ol/docker/docker-server", "run", "defaultServer"]
