ARG REPOSITORY=open-liberty
FROM $REPOSITORY:kernel-java8-ibmsfj

RUN cp /opt/ol/wlp/templates/servers/microProfile1/server.xml /config/server.xml

RUN /opt/ol/wlp/bin/server start && /opt/ol/wlp/bin/server stop && rm -rf /output/resources/security/ /logs/*
