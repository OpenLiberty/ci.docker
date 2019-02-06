ARG REPOSITORY=openliberty/open-liberty
FROM $REPOSITORY:kernel-java8-openj9

RUN mkdir -p /opt/ol/wlp/usr/shared/resources/lib.index.cache \
  && ln -s /opt/ol/wlp/usr/shared/resources/lib.index.cache /lib.index.cache

RUN cp /opt/ol/wlp/templates/servers/springBoot2/server.xml /config/server.xml

