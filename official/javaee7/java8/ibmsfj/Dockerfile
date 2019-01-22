FROM open-liberty:kernel-java8-ibmsfj
ENV KEYSTORE_REQUIRED "true"

RUN cp /opt/ol/wlp/templates/servers/javaee7/server.xml /config/server.xml

RUN /opt/ol/wlp/bin/server start && /opt/ol/wlp/bin/server stop && rm -rf /output/resources/security/ && rm -rf /output/messaging /logs/*
