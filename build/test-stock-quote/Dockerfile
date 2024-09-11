ARG PARENT_IMAGE=openliberty/open-liberty:kernel-slim-ubi
FROM $PARENT_IMAGE

ARG VERBOSE=false

COPY --chown=1001:0 config /config/

# This script will add the requested XML snippets to enable Liberty features and grow image to be fit-for-purpose using featureUtility
RUN features.sh

COPY --chown=1001:0 stock-quote-1.0-SNAPSHOT.war /config/apps/StockQuote.war

# This script will add the requested server configurations, apply any iFixes and populate caches to optimize runtime
RUN configure.sh