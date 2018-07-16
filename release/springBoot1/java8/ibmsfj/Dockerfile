FROM open-liberty:kernel-java8-ibmsfj

COPY ../../server.xml /config/

RUN /opt/ol/wlp/bin/server start && /opt/ol/wlp/bin/server stop && rm -rf /output/resources/security/
