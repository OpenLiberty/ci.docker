# Docker Hub images

There are three different Open Liberty Docker image sets available on Docker Hub:

1. **Official Images**:  available [here](https://hub.docker.com/_/open-liberty), these are re-build automatically anytime something changes in the layers below, and updated with new Open Liberty binaries as they become available (generally every 4 weeks).  The Dockerfiles can be found in the [official](/official) directory.  

1. **Daily Images**: available [here](https://hub.docker.com/r/openliberty/daily), these are daily images from the daily Open Liberty binaries.  The scripts used for this image can be found [here](https://github.com/OpenLiberty/ci.docker.daily).

1. **Community Images**: available [here](https://hub.docker.com/r/openliberty/open-liberty), these are images using OpenJ9 in the JVM.  The Dockerfiles can be found in the [community](/community) directory.

## Building an application image 

According to Docker's best practices you should create a new image (`FROM open-liberty`) which adds a single application and the corresponding configuration. You should avoid configuring the image manually, after it started (unless it is for debugging purposes), because such changes won't be present if you spawn a new container from the image.

Even if you `docker save` the manually configured container, the steps to reproduce the image from `open-liberty` will be lost and you will hinder your ability to update that image.

The key point to take-away from the sections below is that your application Dockerfile should always follow a pattern similar to:

```dockerfile
FROM open-liberty:kernel

# Add my app and config
COPY --chown=1001:0  Sample1.war /config/dropins/
COPY --chown=1001:0  server.xml /config/

# Optional functionality
ARG SSL=true
ARG MP_MONITORING=true

# This script will add the requested XML snippets and grow image to be fit-for-purpose
RUN configure.sh
```

This will result in a Docker image that has your application and configuration pre-loaded, which means you can spawn new fully-configured containers at any time.

## Enterprise Functionality

This section describes the optional enterprise functionality that can be enabled via the Dockerfile during `build` time, by setting particular build-arguments (`ARG`) and calling `RUN configure.sh`.  Each of these options trigger the inclusion of specific configuration via XML snippets, described below:

* `HTTP_ENDPOINT` 
  *  Decription: Add configuration properties for an HTTP endpoint.
  *  XML Snippet Location: [http-ssl-endpoint.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/http-ssl-endpoint.xml) when SSL is enabled. Otherwise [http-endpoint.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/http-endpoint.xml)
* `MP_HEALTH_CHECK`
  *  Decription: Check the health of the environment using Liberty feature `mpHealth-1.0` (implements [MicroProfile Health](https://microprofile.io/project/eclipse/microprofile-health)).
  *  XML Snippet Location: [mp-health-check.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/mp-health-check.xml)
* `MP_MONITORING` 
  *  Decription: Monitor the server runtime environment and application metrics by using Liberty features `mpMetrics-1.1` (implements [Microprofile Metrics](https://microprofile.io/project/eclipse/microprofile-metrics)) and `monitor-1.0`.
  *  XML Snippet Location: [mp-monitoring.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/mp-monitoring.xml)
  *  Note: With this option, `/metrics` endpoint is configured without authentication to support the environments that do not yet support scraping secured endpoints.
* `SSL` 
  *  Decription: Enable SSL in Liberty by adding the `ssl-1.0` feature.
  *  XML Snippet Location:  [ssl.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/ssl.xml).
* `IIOP_ENDPOINT`
  *  Decription: Add configuration properties for an IIOP endpoint.
  *  XML Snippet Location: [iiop-ssl-endpoint.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/iiop-ssl-endpoint.xml) when SSL is enabled. Otherwise, [iiop-endpoint.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/iiop-endpoint.xml).
  *  Note: If using this option, `env.IIOP_ENDPOINT_HOST` environment variable should be set to the server's host. See [IIOP endpoint configuration](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.liberty.autogen.base.doc/ae/rwlp_config_orb.html#iiopEndpoint) for more details.
* `JMS_ENDPOINT`
  *  Decription: Add configuration properties for an JMS endpoint.
  *  XML Snippet Location: [jms-ssl-endpoint.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/jms-ssl-endpoint.xml) when SSL is enabled. Otherwise, [jms-endpoint.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/jms-endpoint.xml)
* `OIDC`
  *  Decription: Enable OpenIdConnect Client function by adding the `openidConnectClient-1.0` feature.
  *  XML Snippet Location: [oidc.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/oidc.xml) 
* `OIDC_CONFIG`
  *  Decription: Enable OpenIdConnect Client configuration to be read from environment variables.  
  *  XML Snippet Location: [oidc-config.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/oidc-config.xml)
  *  Note: The following variables will be read:  OIDC_CLIENT_ID, OIDC_CLIENT_SECRET, OIDC_DISCOVERY_URL.  


### Session Caching

The Liberty session caching feature builds on top of an existing technology called JCache (JSR 107), which provides an API for distributed in-memory caching. There are several providers of JCache implementations. One example is [Hazelcast In-Memory Data Grid](https://hazelcast.org/). Enabling Hazelcast session caching retrieves the Hazelcast client libraries from the [hazelcast/hazelcast](https://hub.docker.com/r/hazelcast/hazelcast/) Docker image, configures Hazelcast by copying a sample [hazelcast.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/), and configures the Liberty server feature [sessionCache-1.0](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_admin_session_persistence_jcache.html) by including the XML snippet [hazelcast-sessioncache.xml](ga/19.0.0.2/kernel/helpers/build/configuration_snippets/hazelcast-sessioncache.xml). By default, the [Hazelcast Discovery Plugin for Kubernetes](https://github.com/hazelcast/hazelcast-kubernetes) will auto-discover its peers within the same Kubernetes namespace. To enable this functionality, the Docker image author can include the following Dockerfile snippet, and choose from either client-server or embedded [topology](https://docs.hazelcast.org/docs/latest-development/manual/html/Hazelcast_Overview/Hazelcast_Topology.html).

```dockerfile
### Hazelcast Session Caching ###
# Copy the Hazelcast libraries from the Hazelcast Docker image
COPY --from=hazelcast/hazelcast --chown=1001:0 /opt/hazelcast/lib/*.jar /opt/ibm/wlp/usr/shared/resources/hazelcast/

# Instruct configure.sh to copy the client topology hazelcast.xml
ARG HZ_SESSION_CACHE=client

# Instruct configure.sh to copy the embedded topology hazelcast.xml and set the required system property
#ARG HZ_SESSION_CACHE=embedded
#ENV JAVA_TOOL_OPTIONS="-Dhazelcast.jcache.provider.type=server ${JAVA_TOOL_OPTIONS}"

## This script will add the requested XML snippets and grow image to be fit-for-purpose
RUN configure.sh
```

## Updating common files

Currently the `common` folder contains the `docker-server` and `README.md` files. When making changes to these files first make
the changes in `common` and then run `sync-master.sh` to copy these files to the directories the files need to be
in for the Docker build. All the files need to be checked into git. Docker won't allow you to copy files from
the parent directory structure, so this allows us to update once, rather than having to update in multiple locations.


