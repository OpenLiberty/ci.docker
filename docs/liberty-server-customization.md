
# How to customize your Liberty Server

## Provide a custom server name

You can provide a custom name for your Liberty server by specifying the `SERVER_NAME` environment variable at container image **build-time**.

### Building from a new image

Specifying the `ENV SERVER_NAME=<your-server-name>` variable allows you to run a Liberty server with a custom name, as in the Dockerfile below.
```Dockerfile
FROM openliberty/open-liberty:kernel-slim-java8-openj9-ubi

ENV SERVER_NAME=liberty1

RUN features.sh

RUN configure.sh
```
Running this container will produce output similar to:
```
Launching liberty1 (Open Liberty 23.0.0.5/wlp-1.0.77.cl230520230514-1901) on Eclipse OpenJ9 VM, version 1.8.0_362-b09 (en_US)
[AUDIT   ] CWWKE0001I: The server liberty1 has been launched.
[AUDIT   ] CWWKG0093A: Processing configuration drop-ins resource: /opt/ol/wlp/usr/servers/liberty1/configDropins/defaults/keystore.xml
[AUDIT   ] CWWKG0093A: Processing configuration drop-ins resource: /opt/ol/wlp/usr/servers/liberty1/configDropins/defaults/open-default-port.xml
[AUDIT   ] CWWKZ0058I: Monitoring dropins for applications.
[AUDIT   ] CWWKF0012I: The server installed the following features: [el-3.0, jsp-2.3, servlet-3.1].
[AUDIT   ] CWWKF0011I: The liberty1 server is ready to run a smarter planet. The liberty1 server started in 0.384 seconds.
```

### Renaming an existing Liberty server

Liberty server configurations and existing output data under `/config` and `/output`, respectively, will be relocated to the server with new name, allowing you to **rename** servers `FROM` any Liberty image.

```Dockerfile
FROM openliberty/open-liberty:kernel-slim-java8-openj9-ubi as staging

ENV SERVER_NAME=liberty1

# Initialize server configuration
COPY --chown=1001:0  server.xml /config/

RUN features.sh

RUN configure.sh

# From an existing Liberty server
FROM staging

# Rename liberty1 to liberty2, retaining /config/server.xml from above
ENV SERVER_NAME=liberty2

RUN features.sh

RUN configure.sh
```

### Renaming a Liberty server using Liberty InstantOn

To rename a Liberty server using Liberty InstantOn, include the `SERVER_NAME` environment variable before configuring the image.

```Dockerfile
FROM icr.io/appcafe/open-liberty:beta-instanton

ENV SERVER_NAME=liberty-instanton

COPY --chown=1001:0 src/main/liberty/config/ /config/
COPY --chown=1001:0 target/*.war /config/apps/

RUN configure.sh
RUN checkpoint.sh applications
```
Running this container will produce output similar to:
```
[AUDIT   ] Launching liberty-instanton (Open Liberty 23.0.0.6-beta/wlp-1.0.77.cl230520230514-1901) on Eclipse OpenJ9 VM, version 17.0.7+7 (en_US)
[AUDIT   ] CWWKC0452I: The Liberty server process resumed operation from a checkpoint in 0.126 seconds.
[AUDIT   ] CWWKF0012I: The server installed the following features: [checkpoint-1.0].
[AUDIT   ] CWWKF0011I: The liberty-instanton server is ready to run a smarter planet. The liberty-instanton server started in 0.130 seconds.
```

### Notes

The new server name changes the directory of stored configurations and server output. For example, for a custom server name `liberty1`.
- `/config -> /opt/ol/wlp/usr/servers/liberty1`
- `/output -> /opt/ol/wlp/output/liberty1`

By using the symbolic links `/config` and `/output`, you can always ensure a correct mapping to the Liberty server's directories. 



