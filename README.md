[![Build Status](https://travis-ci.org/OpenLiberty/ci.docker.svg?branch=master)](https://travis-ci.org/OpenLiberty/ci.docker)

# Container images

1. **Supported Images**
    *  Our recommended set uses Red Hat's [Universal Base Image](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image) as the Operating System and are re-built daily.  They can be found on [Docker Hub](https://hub.docker.com/r/openliberty/open-liberty) or [IBM Cloud](https://cloud.ibm.com/docs/services/Registry?topic=RegistryImages-ibmliberty).
    *  Another set, using Ubuntu as the Operating System, can be found [here](https://hub.docker.com/_/open-liberty).  These are re-built automatically anytime something changes in the layers below.

1. **Daily Images**
    *  Available [here](https://hub.docker.com/r/openliberty/daily), these are daily images from the daily Open Liberty binaries.  The scripts used for this image can be found [here](https://github.com/OpenLiberty/ci.docker.daily).


## Building an application image

According to Docker's best practices you should create a new image (`FROM open-liberty`) which adds a single application and the corresponding configuration. You should avoid configuring the image manually, after it started (unless it is for debugging purposes), because such changes won't be present if you spawn a new container from the image.

Even if you `docker save` the manually configured container, the steps to reproduce the image from `open-liberty` will be lost and you will hinder your ability to update that image.

The key point to take-away from the sections below is that your application Dockerfile should always follow a pattern similar to:

```dockerfile
FROM openliberty/open-liberty:kernel-java8-openj9-ubi

# Add my app and config
COPY --chown=1001:0  Sample1.war /config/dropins/
COPY --chown=1001:0  server.xml /config/

# Default setting for the verbose option
ARG VERBOSE=false

# This script will add the requested XML snippets and grow image to be fit-for-purpose
RUN configure.sh
```

This will result in a Docker image that has your application and configuration pre-loaded, which means you can spawn new fully-configured containers at any time.

## Enterprise Functionality

This section describes the optional enterprise functionality that can be enabled via the Dockerfile during `build` time, by setting particular build-arguments (`ARG`) and calling `RUN configure.sh`.  Each of these options trigger the inclusion of specific configuration via XML snippets (except for `VERBOSE`), described below:

* `HTTP_ENDPOINT`
  *  Description: Add configuration properties for an HTTP endpoint.
  *  XML Snippet Location: [http-ssl-endpoint.xml](/releases/latest/kernel/helpers/build/configuration_snippets/http-ssl-endpoint.xml) when SSL is enabled. Otherwise [http-endpoint.xml](/releases/latest/kernel/helpers/build/configuration_snippets/http-endpoint.xml)
* `MP_HEALTH_CHECK`
  *  Description: Check the health of the environment using Liberty feature `mpHealth-1.0` (implements [MicroProfile Health](https://microprofile.io/project/eclipse/microprofile-health)).
  *  XML Snippet Location: [mp-health-check.xml](/releases/latest/kernel/helpers/build/configuration_snippets/mp-health-check.xml)
* `MP_MONITORING`
  *  Description: Monitor the server runtime environment and application metrics by using Liberty features `mpMetrics-1.1` (implements [Microprofile Metrics](https://microprofile.io/project/eclipse/microprofile-metrics)) and `monitor-1.0`.
  *  XML Snippet Location: [mp-monitoring.xml](/releases/latest/kernel/helpers/build/configuration_snippets/mp-monitoring.xml)
  *  Note: With this option, `/metrics` endpoint is configured without authentication to support the environments that do not yet support scraping secured endpoints.
* `TLS` or `SSL` (SSL is being deprecated)
  *  Description: Enable Transport Security in Liberty by adding the `transportSecurity-1.0` feature (includes support for SSL).
  *  XML Snippet Location:  [keystore.xml](/releases/latest/kernel/helpers/build/configuration_snippets/keystore.xml).
* `IIOP_ENDPOINT`
  *  Description: Add configuration properties for an IIOP endpoint.
  *  XML Snippet Location: [iiop-ssl-endpoint.xml](/releases/latest/kernel/helpers/build/configuration_snippets/iiop-ssl-endpoint.xml) when SSL is enabled. Otherwise, [iiop-endpoint.xml](/releases/latest/kernel/helpers/build/configuration_snippets/iiop-endpoint.xml).
  *  Note: If using this option, `env.IIOP_ENDPOINT_HOST` environment variable should be set to the server's host. See [IIOP endpoint configuration](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.liberty.autogen.base.doc/ae/rwlp_config_orb.html#iiopEndpoint) for more details.
* `JMS_ENDPOINT`
  *  Description: Add configuration properties for an JMS endpoint.
  *  XML Snippet Location: [jms-ssl-endpoint.xml](/releases/latest/kernel/helpers/build/configuration_snippets/jms_ssl_endpoint.xml) when SSL is enabled. Otherwise, [jms-endpoint.xml](/releases/latest/kernel/helpers/build/configuration_snippets/jms_endpoint.xml)
* `VERBOSE`
  *  Description: When set to `true` it outputs the commands and results to stdout from `configure.sh`. Otherwise, default setting is `false` and `configure.sh` is silenced.

## Security 

Single Sign-On can be optionally configured by adding Liberty server variables in an xml file, by passing environment variables (less secure),
or by passing Liberty server variables in through the Liberty operator. See [SECURITY.md](SECURITY.md).

## OpenJ9 Shared Class Cache (SCC)

OpenJ9's SCC allows the VM to store Java classes in an optimized form that can be loaded very quickly, JIT compiled code, and profiling data. Deploying an SCC file together with your application can significantly improve start-up time. The SCC can also be shared by multiple VMs, thereby reducing total memory consumption.

Open Liberty Docker images contain an SCC and (by default) add your application's specific data to the SCC at image build time when your Dockerfile invokes `RUN configure.sh`.

This feature can be controlled via the following variables:

* `OPENJ9_SCC` (environment variable)
  *  Decription: If `"true"`, cache application-specific in an SCC and include it in the image. A new SCC will be created if needed, otherwise data will be added to the existing SCC.
  *  Default: `"true"`.

To customize one of the built-in XML snippets, make a copy of the snippet from Github and edit it locally. Once you have completed your changes, use the `COPY` command inside your Dockerfile to copy the snippet into `/config/configDropins/overrides`. It is important to note that you do not need to set build-arguments (`ARG`) for any customized XML snippets. The following Dockerfile snippet is an example of how you should include the customized snippet.

```dockerfile
COPY --chown=1001:0 <path_to_customized_snippet> /config/configDropins/overrides
```

### Logging

It is important to be able to observe the logs emitted by Open Liberty when it is running in docker. A best practice method would be to emit the logs in JSON and to then consume it with a logging stack of your choice.

Configure your Open Liberty docker image to emit JSON formatted logs to the console/standard-out with your selection of liberty logging events by creating  a `bootstrap.properties` file with the following properties. You can also disable writing to the messages.log or trace.log files if you don't need them.
```
# direct events to console in json format
com.ibm.ws.logging.console.log.level=info
com.ibm.ws.logging.console.format=json
com.ibm.ws.logging.console.source=message,trace,accessLog,ffdc,audit

# disable writing to messages.log by not including any sources (optional)
com.ibm.ws.logging.message.format=json
com.ibm.ws.logging.message.source=

# disable writing to trace.log by only sending trace data to console (optional)
com.ibm.ws.logging.trace.file.name=stdout
```
Make sure to include the file you have just created into your Open Liberty Dockerfile.
```dockerfile
COPY --chown=1001:0  bootstrap.properties /config/
```

Many of these configuration changes can also be set during container invocation by using the Docker command's '-e' option to pass in an environment variable value.
```
docker run -d -p 80:9080 -p 443:9443 -e WLP_LOGGING_CONSOLE_FORMAT=JSON -e WLP_LOGGING_CONSOLE_LOGLEVEL=info -e WLP_LOGGING_CONSOLE_SOURCE=message,trace,accessLog,ffdc,audit open-liberty:latest
```

For more information regarding the configuration of Open Liberty's logging capabilities see: https://openliberty.io/docs/ref/general/#logging.html

### Session Caching

The Liberty session caching feature builds on top of an existing technology called JCache (JSR 107), which provides an API for distributed in-memory caching. There are several providers of JCache implementations. The configuration for two such providers, Infinispan and Hazelcast, are outlined below.

1. **Infinispan** - One JCache provider is the open source project [Infinispan](https://infinispan.org/), which is the basis for Red Hat Data Grid. Enabling Infinispan session caching retrieves the Infinispan client libraries from the [Infinispan JCACHE (JSR 107) Remote Implementation](https://mvnrepository.com/artifact/org.infinispan/infinispan-jcache-remote) maven repository, and configures the necessary infinispan.client.hotrod.* properties and the Liberty server feature [sessionCache-1.0](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_admin_session_persistence_jcache.html) by including the XML snippet [infinispan-client-sessioncache.xml](/releases/latest/kernel/helpers/build/configuration_snippets/infinispan-client-sessioncache.xml).

    *  **Setup Infinispan Service** - Configuring Liberty session caching with Infinispan depends on an Infinispan service being available in your Kubernetes environment. It is preferable to create your Infinispan service by utilizing the [Infinispan Operator](https://infinispan.org/infinispan-operator/master/operator.html). The [Infinispan Operator Tutorial](https://github.com/infinispan/infinispan-simple-tutorials/tree/master/operator) provides a good example of getting started with Infinispan in OpenShift.

    *  **Install Client Jars and Set INFINISPAN_SERVICE_NAME** - To enable Infinispan functionality in Liberty, the Docker image author can use the Dockerfile provided below. This Dockerfile assumes an Infinispan service name of `example-infinispan`, which is the default used in the [Infinispan Operator Tutorial](https://github.com/infinispan/infinispan-simple-tutorials/tree/master/operator). To customize your Infinispan service see [Creating Infinispan Clusters](https://infinispan.org/infinispan-operator/master/operator.html#creating_minimal_clusters-start). The `INFINISPAN_SERVICE_NAME` environment variable must be set at build time as shown in the example Dockerfile, or overridden at image deploy time.
        *  **TIP** - If your Infinispan deployment and Liberty deployment are in different namespaces/projects, you will need to set the `INFINISPAN_HOST`, `INFINISPAN_PORT`, `INFINISPAN_USER`, and `INFINISPAN_PASS` environment variables in addition to the `INFINISPAN_SERVICE_NAME` environment variable. This is due to the Liberty deployment not having the access to the Infinispan service environment variables it requires.

    ```dockerfile
    ### Infinispan Session Caching ###
    FROM openliberty/open-liberty:kernel-java8-openj9-ubi AS infinispan-client
    
    # Install Infinispan client jars
    USER root
    RUN infinispan-client-setup.sh
    USER 1001
    
    FROM openliberty/open-liberty:kernel-java8-openj9-ubi AS open-liberty-infinispan
    
    # Copy Infinispan client jars to Open Liberty shared resources
    COPY --chown=1001:0 --from=infinispan-client /opt/ol/wlp/usr/shared/resources/infinispan /opt/ol/wlp/usr/shared/resources/infinispan
    
    # Instruct configure.sh to use Infinispan for session caching.
    # This should be set to the Infinispan service name.
    # TIP - Run the following oc/kubectl command with admin permissions to determine this value:
    #       oc get infinispan -o jsonpath={.items[0].metadata.name}
    ENV INFINISPAN_SERVICE_NAME=example-infinispan
    
    # Uncomment and set to override auto detected values.
    # These are normally not needed if running in a Kubernetes environment.
    # One such scenario would be when the Infinispan and Liberty deployments are in different namespaces/projects.
    #ENV INFINISPAN_HOST=
    #ENV INFINISPAN_PORT=
    #ENV INFINISPAN_USER=
    #ENV INFINISPAN_PASS=
    
    # This script will add the requested XML snippets and grow image to be fit-for-purpose
    RUN configure.sh
    ```

    *  **Mount Infinispan Secret** - Finally, the Infinispan generated secret must be mounted as a volume under the mount point of `/platform/bindings/secret/` on Liberty containers. The default location of `/platform/bindings/secret/` can to be overridden by setting the `LIBERTY_INFINISPAN_SECRET_DIR` environment variable. When using the Infinispan Operator, this secret is automatically generated as part of the Infinispan service with the name of `<INFINISPAN_CLUSTER_NAME>-generated-secret`. For the mounting of this secret to succeed, the Infinispan Operator and Liberty must share the same namespace. If they do not share the same namespace, the `INFINISPAN_HOST`, `INFINISPAN_PORT`, `INFINISPAN_USER`, and `INFINISPAN_PASS` environment variables can be used instead(see the dockerfile example above). For an example of mounting this secret, review the `volumes` and `volumeMounts` portions of the YAML below.

    ```yaml
    ...
        spec:
          volumes:
          - name: infinispan-secret-volume
            secret:
              secretName: example-infinispan-generated-secret
          containers:
          - name: servera-container
            image: ol-runtime-infinispan-client:1.0.0
            ports:
            - containerPort: 9080
            volumeMounts:
            - name: infinispan-secret-volume
              readOnly: true
              mountPath: "/config/liberty-infinispan-secret"
    ...

    ```

2. **Hazelcast** - Another JCache provider is [Hazelcast In-Memory Data Grid](https://hazelcast.org/). Enabling Hazelcast session caching retrieves the Hazelcast client libraries from the [hazelcast/hazelcast](https://hub.docker.com/r/hazelcast/hazelcast/) Docker image, configures Hazelcast by copying a sample [hazelcast.xml](/releases/latest/kernel/helpers/build/configuration_snippets/), and configures the Liberty server feature [sessionCache-1.0](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_admin_session_persistence_jcache.html) by including the XML snippet [hazelcast-sessioncache.xml](/releases/latest/kernel/helpers/build/configuration_snippets/hazelcast-sessioncache.xml). By default, the [Hazelcast Discovery Plugin for Kubernetes](https://github.com/hazelcast/hazelcast-kubernetes) will auto-discover its peers within the same Kubernetes namespace. To enable this functionality, the Docker image author can include the following Dockerfile snippet, and choose from either client-server or embedded [topology](https://docs.hazelcast.org/docs/latest-dev/manual/html-single/#hazelcast-topology).

    ```dockerfile
    ### Hazelcast Session Caching ###
    # Copy the Hazelcast libraries from the Hazelcast Docker image
    COPY --from=hazelcast/hazelcast --chown=1001:0 /opt/hazelcast/lib/*.jar /opt/ol/wlp/usr/shared/resources/hazelcast/
    
    # Instruct configure.sh to copy the client topology hazelcast.xml
    ARG HZ_SESSION_CACHE=client
    
    # Default setting for the verbose option
    ARG VERBOSE=false
    
    # Instruct configure.sh to copy the embedded topology hazelcast.xml and set the required system property
    #ARG HZ_SESSION_CACHE=embedded
    #ENV JAVA_TOOL_OPTIONS="-Dhazelcast.jcache.provider.type=server ${JAVA_TOOL_OPTIONS}"
    
    ## This script will add the requested XML snippets and grow image to be fit-for-purpose
    RUN configure.sh
    ```

