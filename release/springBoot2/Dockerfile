FROM openliberty/open-liberty:kernel

RUN mkdir /opt/ol/wlp/usr/shared/resources/lib.index.cache \
  && ln -s /opt/ol/wlp/usr/shared/resources/lib.index.cache /lib.index.cache

COPY server.xml /config/

