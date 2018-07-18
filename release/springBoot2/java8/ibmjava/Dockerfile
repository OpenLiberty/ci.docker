FROM open-liberty:kernel-java8-ibm

RUN mkdir -p /opt/ol/wlp/usr/shared/resources/lib.index.cache \
  && ln -s /opt/ol/wlp/usr/shared/resources/lib.index.cache /lib.index.cache

COPY server.xml /config/

RUN /opt/ol/wlp/bin/server start && /opt/ol/wlp/bin/server stop && rm -rf /output/resources/security/
