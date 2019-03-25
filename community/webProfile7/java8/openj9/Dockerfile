FROM openliberty/open-liberty:kernel-java8-openj9
ENV KEYSTORE_REQUIRED "true"

RUN cp /opt/ol/wlp/templates/servers/webProfile7/server.xml /config/server.xml

RUN /opt/ol/wlp/bin/server start && /opt/ol/wlp/bin/server stop && rm -rf /output/resources/security/ /output/messaging /logs/* $WLP_OUTPUT_DIR/.classCache && chmod -R g+rwx /opt/ol/wlp/output/*
