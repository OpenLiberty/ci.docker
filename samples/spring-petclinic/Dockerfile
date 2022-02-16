ARG IMAGE=openliberty/open-liberty:kernel-slim-java8-openj9-ubi
FROM ${IMAGE} as staging

# Copy server config so springBootUtility can be downloaded by featureUtility in the next step
COPY --chown=1001:0 server.xml /config/server.xml

# This script will add the requested XML snippets to enable Liberty features and grow image to be fit-for-purpose using featureUtility
RUN features.sh

COPY --chown=1001:0 spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar /staging/myFatApp.jar

RUN springBootUtility thin \
 --sourceAppPath=/staging/myFatApp.jar \
 --targetThinAppPath=/staging/myThinApp.jar \
 --targetLibCachePath=/staging/lib.index.cache

FROM ${IMAGE}
COPY --chown=1001:0 server.xml /config

# This script will add the requested XML snippets to enable Liberty features and grow image to be fit-for-purpose using featureUtility
RUN features.sh

COPY --from=staging --chown=1001:0 /staging/lib.index.cache /lib.index.cache
COPY --from=staging --chown=1001:0 /staging/myThinApp.jar /config/dropins/spring/myThinApp.jar

ARG VERBOSE=false
# This script will add the requested server configurations, apply any iFixes and populate caches to optimize runtime
RUN configure.sh
