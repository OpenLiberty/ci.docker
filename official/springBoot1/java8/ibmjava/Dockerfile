FROM open-liberty:kernel-java8-ibm

RUN mkdir -p /opt/ol/wlp/usr/shared/resources/lib.index.cache \
  && chown -R 1001:0 /opt/ol/wlp/usr/shared/resources/lib.index.cache \
  && chmod -R g+rw /opt/ol/wlp/usr/shared/resources/lib.index.cache \
  && ln -s /opt/ol/wlp/usr/shared/resources/lib.index.cache /lib.index.cache

RUN cp /opt/ol/wlp/templates/servers/springBoot1/server.xml /config/server.xml

RUN /opt/ol/wlp/bin/server start && /opt/ol/wlp/bin/server stop && rm -rf /output/resources/security/ /output/messaging /logs/* $WLP_OUTPUT_DIR/.classCache && chmod -R g+rwx /opt/ol/wlp/output/*
