ARG IMAGE=openliberty/open-liberty:kernel-java11-openj9-ubi
FROM openliberty/open-liberty:kernel-java11-openj9-ubi

COPY --chown=1001:0 config /config/
COPY --chown=1001:0 trader-1.0-SNAPSHOT.war /config/apps/TraderUI.war

ARG VERBOSE=false

RUN configure.sh
