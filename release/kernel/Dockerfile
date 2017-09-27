
FROM ibmjava:8-jre

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Open Liberty
ENV LIBERTY_VERSION 17.0.0_03

RUN wget http://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/wasliberty-open-liberty/io/openliberty/openliberty-runtime/17.0.0.3-RC/openliberty-runtime-17.0.0.3-RC.zip -U UA-Open-Liberty-Docker -O /tmp/wlp.zip \
   && unzip -q /tmp/wlp.zip -d /opt/ol \
   && rm /tmp/wlp.zip

ENV PATH=/opt/ol/wlp/bin:$PATH

# Set Path Shortcuts
ENV LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ol/wlp/output
RUN mkdir /logs \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ol/wlp/usr/servers/defaultServer /config

# Configure WebSphere Liberty
RUN /opt/ol/wlp/bin/server create \
    && rm -rf $WLP_OUTPUT_DIR/.classCache /output/workarea
COPY docker-server /opt/ol/docker/

EXPOSE 9080 9443

CMD ["/opt/ol/docker/docker-server", "run", "defaultServer"]
