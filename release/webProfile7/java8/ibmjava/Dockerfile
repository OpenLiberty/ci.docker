FROM open-liberty:kernel-java8-ibm

RUN cp /opt/ol/wlp/templates/servers/webProfile7/server.xml /config/server.xml

RUN /opt/ol/wlp/bin/server start && /opt/ol/wlp/bin/server stop && rm -rf /output/resources/security/
