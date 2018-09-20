FROM openliberty/open-liberty:kernel-java8-openj9

RUN mkdir -p /opt/ol/wlp/usr/shared/resources/lib.index.cache \
  && ln -s /opt/ol/wlp/usr/shared/resources/lib.index.cache /lib.index.cache

RUN cp /opt/ol/wlp/templates/servers/springBoot1/server.xml /config/server.xml

