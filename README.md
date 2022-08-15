[![Build Status](https://travis-ci.org/OpenLiberty/ci.docker.svg?branch=master)](https://travis-ci.org/OpenLiberty/ci.docker)

# Open Liberty Images

- [Open Liberty Images](#open-liberty-images)
  - [Container Images](#container-images)
  - [Building an Application Image](#building-an-application-image)
  - [Enterprise Functionality](#enterprise-functionality)
  - [Security](#security)
  - [OpenJ9 Shared Class Cache (SCC)](#openj9-shared-class-cache-scc)
  - [Logging](#logging)
  - [Session Caching](#session-caching)
  - [Applying Interim Fixes](#applying-interim-fixes)
  - [Known Issues](#known-issues)
    - [Generating system dumps for pods in Kubernetes](#generating-system-dumps-for-pods-in-kubernetes)
  
----

## Container Images

1. **Supported Images**
    *  Our recommended set uses Red Hat's [Universal Base Image](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image) as the Operating System and are re-built daily. They are available from [IBM Container Registry](docs/icr-images.md) and [Docker Hub](https://hub.docker.com/r/openliberty/open-liberty).
    *  Another set, using Ubuntu as the Operating System, can be found on [Docker Hub](https://hub.docker.com/_/open-liberty).  These are re-built automatically anytime something changes in the layers below.

1. **Beta Images**
    * The latest Open Liberty beta runtime can be found on [Docker Hub](https://hub.docker.com/_/open-liberty). It's available via the `beta` and `beta-java11` tags. 

1. **Daily Images**
    *  Images with the daily Open Liberty binaries are available [here](https://hub.docker.com/r/openliberty/daily).  The scripts used for this image can be found [here](https://github.com/OpenLiberty/ci.docker.daily).

_**Important Notice:**_ The `kernel` **tag is now deprecated** and it will not be updated (starting with 20.0.0.11). The new tag, that provides kernel binary, is named `kernel-slim`.

## Building an Application Image

According to best practices for container images, you should create a new image (`FROM icr.io/appcafe/open-liberty:`) which adds a single application and the corresponding configuration. You should avoid configuring the container manually once it started, unless it is for debugging purposes, because such changes won't persist if you spawn a new container from the image.

Your application image template should follow a pattern similar to:

```dockerfile
FROM icr.io/appcafe/open-liberty:kernel-slim-java8-openj9-ubi

# Add Liberty server configuration including all necessary features
COPY --chown=1001:0  server.xml /config/

# Modify feature repository (optional)
# A sample is in the 'Getting Required Features' section below
COPY --chown=1001:0 featureUtility.properties /opt/ol/wlp/etc/

# This script will add the requested XML snippets to enable Liberty features and grow image to be fit-for-purpose using featureUtility. 
# Only available in 'kernel-slim'. The 'full' tag already includes all features for convenience.
RUN features.sh

# Add interim fixes (optional)
COPY --chown=1001:0  interim-fixes /opt/ol/fixes/

# Add app
COPY --chown=1001:0  Sample1.war /config/dropins/

# This script will add the requested server configurations, apply any interim fixes and populate caches to optimize runtime
RUN configure.sh
```

This will result in a container image that has your application and configuration pre-loaded, which means you can spawn new fully-configured containers at any time.

Refer to [Open Liberty Docs](https://openliberty.io/docs) for server configuration (server.xml) information.

### Getting Required Features

The `kernel-slim` tag provides just the bare minimum server. You can grow it to include the features needed by your application by invoking `features.sh`. 
Liberty features are downloaded from Maven Central repository by default. But you can specify alternatives using `/opt/ol/wlp/etc/featureUtility.properties`: 
```
remoteRepo.url=https://my-remote-server/secure/maven2
remoteRepo.user=operator
remoteRepo.password={aes}KM8dhwcv892Ss1sawu9R+
```

Refer to [Repository and proxy modifications](https://openliberty.io/docs/ref/command/featureUtility-modifications.html) for more information.

## Enterprise Functionality

This section describes the optional enterprise functionality that can be enabled via the Dockerfile during `build` time, by setting particular build-arguments (`ARG`) and calling `RUN configure.sh`.  Each of these options trigger the inclusion of specific configuration via XML snippets (except for `VERBOSE`), described below:

* `TLS` (`SSL` is deprecated)
  *  Description: Enable Transport Security in Liberty by adding the `transportSecurity-1.0` feature (includes support for SSL).
  *  XML Snippet Location:  [keystore.xml](/releases/latest/kernel-slim/helpers/build/configuration_snippets/keystore.xml).
* `HZ_SESSION_CACHE`
  *  Description: Enable the persistence of HTTP sessions using JCache by adding the `sessionCache-1.0` feature.
  *  XML Snippet Location: [hazelcast-sessioncache.xml](/releases/latest/kernel-slim/helpers/build/configuration_snippets/hazelcast-sessioncache.xml)
* `VERBOSE`
  *  Description: When set to `true` it outputs the commands and results to stdout from `configure.sh`. Otherwise, default setting is `false` and `configure.sh` is silenced.

### Deprecated Enterprise Functionality

The following enterprise functionalities are now **deprecated**. You should **stop** using them. They are still available in `full` but not available in `kernel-slim`:

* `HTTP_ENDPOINT`
  *  Description: Add configuration properties for an HTTP endpoint.
  *  XML Snippet Location: [http-ssl-endpoint.xml](/releases/latest/full/helpers/build/configuration_snippets/http-ssl-endpoint.xml) when SSL is enabled. Otherwise [http-endpoint.xml](/releases/latest/full/helpers/build/configuration_snippets/http-endpoint.xml)
* `MP_HEALTH_CHECK`
  *  Description: Check the health of the environment using Liberty feature `mpHealth-1.0` (implements [MicroProfile Health](https://microprofile.io/project/eclipse/microprofile-health)).
  *  XML Snippet Location: [mp-health-check.xml](/releases/latest/full/helpers/build/configuration_snippets/mp-health-check.xml)
* `MP_MONITORING`
  *  Description: Monitor the server runtime environment and application metrics by using Liberty features `mpMetrics-1.1` (implements [Microprofile Metrics](https://microprofile.io/project/eclipse/microprofile-metrics)) and `monitor-1.0`.
  *  XML Snippet Location: [mp-monitoring.xml](/releases/latest/full/helpers/build/configuration_snippets/mp-monitoring.xml)
  *  Note: With this option, `/metrics` endpoint is configured without authentication to support the environments that do not yet support scraping secured endpoints.
* `IIOP_ENDPOINT`
  *  Description: Add configuration properties for an IIOP endpoint.
  *  XML Snippet Location: [iiop-ssl-endpoint.xml](/releases/latest/full/helpers/build/configuration_snippets/iiop-ssl-endpoint.xml) when SSL is enabled. Otherwise, [iiop-endpoint.xml](/releases/latest/full/helpers/build/configuration_snippets/iiop-endpoint.xml).
  *  Note: If using this option, `env.IIOP_ENDPOINT_HOST` environment variable should be set to the server's host. See [IIOP endpoint configuration](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.liberty.autogen.base.doc/ae/rwlp_config_orb.html#iiopEndpoint) for more details.
* `JMS_ENDPOINT`
  *  Description: Add configuration properties for an JMS endpoint.
  *  XML Snippet Location: [jms-ssl-endpoint.xml](/releases/latest/full/helpers/build/configuration_snippets/jms_ssl_endpoint.xml) when SSL is enabled. Otherwise, [jms-endpoint.xml](/releases/latest/full/helpers/build/configuration_snippets/jms_endpoint.xml)

## Security

Single Sign-On can be optionally configured by adding Liberty server variables in an xml file, by passing environment variables (less secure),
or by passing Liberty server variables in through the Liberty operator. See [SECURITY.md](SECURITY.md).

## OpenJ9 Shared Class Cache (SCC)

OpenJ9's SCC allows the VM to store Java classes in an optimized form that can be loaded very quickly, JIT compiled code, and profiling data. Deploying an SCC file together with your application can significantly improve start-up time. The SCC can also be shared by multiple VMs, thereby reducing total memory consumption.

Open Liberty container images contain an SCC and (by default) add your application's specific data to the SCC at image build time when your Dockerfile invokes `RUN configure.sh`.

Note that currently some content in the SCC is sensitive to heap geometry. If the server is started with options that cause heap geometry to significantly change from when the SCC was created that content will not be used and you may observe fluctuations in start-up performance. Specifying a smaller `-Xmx` value increases the chances of obtaining a heap geometry that's compatible with the AOT code.

This feature can be controlled via the following variables:

* `OPENJ9_SCC` (environment variable)
  *  Decription: If `"true"`, cache application-specific in an SCC and include it in the image. A new SCC will be created if needed, otherwise data will be added to the existing SCC.
  *  Default: `"true"`.

To customize one of the built-in XML snippets, make a copy of the snippet from Github and edit it locally. Once you have completed your changes, use the `COPY` command inside your Dockerfile to copy the snippet into `/config/configDropins/overrides`. It is important to note that you do not need to set build-arguments (`ARG`) for any customized XML snippets. The following Dockerfile snippet is an example of how you should include the customized snippet.

```dockerfile
COPY --chown=1001:0 <path_to_customized_snippet> /config/configDropins/overrides
```

## Logging

It is important to be able to observe the logs emitted by Open Liberty when it is running in a container. A best practice method would be to emit the logs in JSON and to then consume it with a logging stack of your choice.

Configure your Open Liberty container image to emit JSON formatted logs to the console/standard-out with your selection of liberty logging events by creating  a `bootstrap.properties` file with the following properties. You can also disable writing to the messages.log or trace.log files if you don't need them.
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

These environment variables can be set when running container as well. This can be achieved by using the run command's '-e' option to pass in an environment variable value.
```
docker run -d -p 80:9080 -p 443:9443 -e WLP_LOGGING_CONSOLE_FORMAT=JSON -e WLP_LOGGING_CONSOLE_LOGLEVEL=info -e WLP_LOGGING_CONSOLE_SOURCE=message,trace,accessLog,ffdc,audit open-liberty:latest
```

For more information regarding the configuration of Open Liberty's logging capabilities see: https://openliberty.io/docs/ref/general/#log-trace-configuration.html

## Session Caching

The Liberty session caching feature builds on top of an existing technology called JCache (JSR 107), which provides an API for distributed in-memory caching. There are several providers of JCache implementations. The configuration for two such providers, Infinispan and Hazelcast, are outlined below.

1. **Infinispan** - One JCache provider is the open source project [Infinispan](https://infinispan.org/), which is the basis for Red Hat Data Grid. Enabling Infinispan session caching retrieves the Infinispan client libraries from the [Infinispan JCACHE (JSR 107) Remote Implementation](https://mvnrepository.com/artifact/org.infinispan/infinispan-jcache-remote) maven repository, and configures the necessary infinispan.client.hotrod.* properties and the Liberty server feature [sessionCache-1.0](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_admin_session_persistence_jcache.html) by including the XML snippet [infinispan-client-sessioncache.xml](/releases/latest/kernel-slim/helpers/build/configuration_snippets/infinispan-client-sessioncache.xml).

    *  **Setup Infinispan Service** - Configuring Liberty session caching with Infinispan depends on an Infinispan service being available in your Kubernetes environment. It is preferable to create your Infinispan service by utilizing the [Infinispan Operator](https://infinispan.org/infinispan-operator/master/operator.html). The [Infinispan Operator Tutorial](https://github.com/infinispan/infinispan-simple-tutorials/tree/master/operator) provides a good example of getting started with Infinispan in OpenShift.

    *  **Install Client Jars and Set INFINISPAN_SERVICE_NAME** - To enable Infinispan functionality in Liberty, the container image author can use the Dockerfile provided below. This Dockerfile assumes an Infinispan service name of `example-infinispan`, which is the default used in the [Infinispan Operator Tutorial](https://github.com/infinispan/infinispan-simple-tutorials/tree/master/operator). To customize your Infinispan service see [Creating Infinispan Clusters](https://infinispan.org/infinispan-operator/master/operator.html#creating_minimal_clusters-start). The `INFINISPAN_SERVICE_NAME` environment variable must be set at build time as shown in the example Dockerfile, or overridden at image deploy time.
        *  **TIP** - If your Infinispan deployment and Liberty deployment are in different namespaces/projects, you will need to set the `INFINISPAN_HOST`, `INFINISPAN_PORT`, `INFINISPAN_USER`, and `INFINISPAN_PASS` environment variables in addition to the `INFINISPAN_SERVICE_NAME` environment variable. This is due to the Liberty deployment not having the access to the Infinispan service environment variables it requires.

    ```dockerfile
    ### Infinispan Session Caching ###
    FROM icr.io/appcafe/open-liberty:kernel-slim-java8-openj9-ubi AS infinispan-client

    # Install Infinispan client jars
    USER root
    RUN infinispan-client-setup.sh
    USER 1001

    FROM icr.io/appcafe/open-liberty:kernel-slim-java8-openj9-ubi AS open-liberty-infinispan

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

    *  **Mount Infinispan Secret** - Finally, the Infinispan generated secret must be mounted as a volume under the mount point of `/platform/bindings/infinispan/secret/` on Liberty containers. The default , for versions latest and 20.0.0.6+, of `/platform/bindings/infinispan/secret/` can to be overridden by setting the `LIBERTY_INFINISPAN_SECRET_DIR` environment variable. When using the Infinispan Operator, this secret is automatically generated as part of the Infinispan service with the name of `<INFINISPAN_CLUSTER_NAME>-generated-secret`. For the mounting of this secret to succeed, the Infinispan Operator and Liberty must share the same namespace. If they do not share the same namespace, the `INFINISPAN_HOST`, `INFINISPAN_PORT`, `INFINISPAN_USER`, and `INFINISPAN_PASS` environment variables can be used instead(see the Dockerfile example above). For an example of mounting this secret, review the `volumes` and `volumeMounts` portions of the YAML below.

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
              mountPath: "/platform/bindings/infinispan/secret"
    ...

    ```

2. **Hazelcast** - Another JCache provider is [Hazelcast In-Memory Data Grid](https://hazelcast.org/). Enabling Hazelcast session caching retrieves the Hazelcast client libraries from the [hazelcast/hazelcast](https://hub.docker.com/r/hazelcast/hazelcast/) container image, configures Hazelcast by copying a sample [hazelcast.xml](/releases/latest/kernel-slim/helpers/build/configuration_snippets/), and configures the Liberty server feature [sessionCache-1.0](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_admin_session_persistence_jcache.html) by including the XML snippet [hazelcast-sessioncache.xml](/releases/latest/kernel-slim/helpers/build/configuration_snippets/hazelcast-sessioncache.xml). By default, the [Hazelcast Discovery Plugin for Kubernetes](https://github.com/hazelcast/hazelcast-kubernetes) will auto-discover its peers within the same Kubernetes namespace. To enable this functionality, the container image author can include the following Dockerfile snippet, and choose from either client-server or embedded [topology](https://docs.hazelcast.org/docs/latest-dev/manual/html-single/#hazelcast-topology).

    ```dockerfile
    ### Hazelcast Session Caching ###
    # Copy the Hazelcast libraries from the Hazelcast container image
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

## Applying Interim Fixes

The process to apply interim fixes (iFix) is defined [here](releases/applying-ifixes/README.md).

## Known Issues

### Generating system dumps for pods in Kubernetes

When generating server dump for a Liberty server running in a container in a pod on a Kubernetes cluster (including OpenShift), the server dump command might cause the following error:

```console
$ server dump defaultServer --archive=all.dump.zip --include=system
Dumping server defaultServer.
CWWKE0009E: The system cannot find the following file and this file will not be included in the server dump archive: /opt/ibm/wlp/output/defaultServer/The core file created by child process with pid = 252052 was not found. Expected to find core file with name "/opt/ibm/wlp/output/defaultServer/core.252052"
Server defaultServer dump complete in /opt/ibm/wlp/output/defaultServer/all.dump.zip.
```

This issue happens when the server dump command includes `--include=system` and if there is a `|` (pipe) contained in the `core_pattern` file in the container:

Example on a OpenShift 4.3 cluster:
```console
$ cat /proc/sys/kernel/core_pattern
|/usr/lib/systemd/systemd-coredump %P %u %g %s %t %c %h %e
```

Another example on a Kubernetes cluster:
```console
$ cat /proc/sys/kernel/core_pattern
|/usr/share/apport/apport %p %s %c %d %P %E
```

If the first character of the `/proc/sys/kernel/core_pattern` file is a pipe symbol (`|`), then the remainder of the line is interpreted as the command-line for a user-space program (or script) that is to be executed and processing the dump.
 
To access the core dump:

* If the program is `/usr/lib/systemd/systemd-coredump`, then the core dump should go to `/var/lib/systemd/coredump/` by default (overridden configuration in `/etc/systemd/coredump.conf`). To get this coredump, from the host, run `sudo coredumpctl -o core.dmp dump ${PID}` and transfer the `core.dmp` file.
* If the program is `/usr/share/apport/apport`, then the core dump should go to `/var/crash/` by default (overridden configuration in `/etc/default/apport`). To get this core dump, from the host, gather the file from `/var/crash` on the host.

If the core dump is not found in these locations, review the host’s kernel log (e.g. `journalctl`) to see if there were errors in those programs. 

When the issue is encountered, the user encounters the following messages in the logs from the server:

```console
[AUDIT   ] CWWKE0057I: Introspect request received. The server is dumping status.
JVMDUMP034I User requested System dump using '/opt/ibm/wlp/output/defaultServer/core.20200605.191845.1.0001.dmp' through com.ibm.jvm.Dump.triggerDump
JVMPORT030W /proc/sys/kernel/core_pattern setting "|/usr/lib/systemd/systemd-coredump %P %u %g %s %t %c %h %e" specifies that the core dump is to be piped to an external program.  Attempting to rename either core or core.190.
JVMDUMP012E Error in System dump: The core file created by child process with pid = 190 was not found. Expected to find core file with name "/opt/ibm/wlp/output/defaultServer/core.190"
[AUDIT   ] CWWKE0068I: Java dump created: /opt/ibm/wlp/output/defaultServer/The core file created by child process with pid = 190 was not found. Expected to find core file with name "/opt/ibm/wlp/output/defaultServer/core.190"
```

Since JVM cannot find the system dump, it is not able to add some useful metadata to the core dump but this is usually not required. An example of this information includes some extra memory region metadata for the info map command in `jdmpview` which is useful for native memory leak analysis.

Users generating other types of dumps such as thread dump and heap dump should not see this issue. 
