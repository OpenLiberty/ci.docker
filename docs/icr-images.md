
# IBM Container Registry (ICR)

Open Liberty container images are available from the IBM Container Registry (ICR) at `icr.io/appcafe/open-liberty`. Our recommendation is to use ICR instead of Docker Hub since ICR doesn't impose rate limits on image pulls. Images can be pulled from ICR without authentication. Only images with Universal Base Image (UBI) as the Operating System are available in ICR.

The images for the latest Liberty release and the last two quarterly releases (versions ending in _.3_, _.6_, _.9_ and _.12_) are available and are refreshed regularly (every 1-2 weeks) to include fixes for the operating system (OS) and Java.

Available image tags are listed below. The tags use the following naming convention. For more information on tags, see [Container image tags naming conventions](https://openliberty.io/docs/latest/container-images.html#tags) documentation.
```
<optional fix pack version-><liberty image type>-<java version>-<java type>-<base image type>
```

Liberty images with Java 21 are based on UBI 9 minimal and include IBM Semeru Runtimes for Java 21 JRE. This combination offers a compact and effective Java runtime that is suited for applications that need Java 21.

Liberty images with Java 8, 11 and 17 and with the `openj9` type are based on UBI 8 standard and include IBM Semeru Runtime for the respective Java version with the JDK. Images with the `ibmjava` type are based on UBI 8 standard and include IBM Java 8 JRE.

The `latest` tag simplifies pulling the full latest Open Liberty release with the latest Java JRE. It is an alias for the `full-java21-openj9-ubi-minimal` tag. If you do not specify a tag value, `latest` is used by default.

The `beta` tag is based on UBI 9 minimal and the latest Java JRE and provides the most recent beta release of Liberty, which includes all the features and capabilities from the most recent release, plus new and updated features that are currently in development.

Append a tag to `icr.io/appcafe/open-liberty` to pull a specific image. For example: 
```
icr.io/appcafe/open-liberty:24.0.0.3-kernel-slim-java17-openj9-ubi
```

Available images can be listed using [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-getting-started). Log in with your IBMid prior to running the following commands. Note that authentication is only required to list the images. **Images can be pulled from ICR without authentication**: 
```
ibmcloud cr region-set global 
ibmcloud cr images --restrict appcafe/open-liberty
```

## Latest version

The following tags include the most recent Open Liberty version: `24.0.0.5`

```
kernel-slim-java21-openj9-ubi-minimal
kernel-slim-java17-openj9-ubi
kernel-slim-java11-openj9-ubi
kernel-slim-java8-openj9-ubi
kernel-slim-java8-ibmjava-ubi

full-java21-openj9-ubi-minimal
full-java17-openj9-ubi
full-java11-openj9-ubi
full-java8-openj9-ubi
full-java8-ibmjava-ubi

latest
beta
```

## Beta

The `beta` tag includes all the features and capabilities from the most recent release, plus new and updated features that are currently in development for the next release.

```
beta
```

## 24.0.0.5

```
24.0.0.5-kernel-slim-java21-openj9-ubi-minimal
24.0.0.5-kernel-slim-java17-openj9-ubi
24.0.0.5-kernel-slim-java11-openj9-ubi
24.0.0.5-kernel-slim-java8-openj9-ubi
24.0.0.5-kernel-slim-java8-ibmjava-ubi

24.0.0.5-full-java21-openj9-ubi-minimal
24.0.0.5-full-java17-openj9-ubi
24.0.0.5-full-java11-openj9-ubi
24.0.0.5-full-java8-openj9-ubi
24.0.0.5-full-java8-ibmjava-ubi
```

## 24.0.0.3

```
24.0.0.3-kernel-slim-java21-openj9-ubi-minimal
24.0.0.3-kernel-slim-java17-openj9-ubi
24.0.0.3-kernel-slim-java11-openj9-ubi
24.0.0.3-kernel-slim-java8-openj9-ubi
24.0.0.3-kernel-slim-java8-ibmjava-ubi

24.0.0.3-full-java21-openj9-ubi-minimal
24.0.0.3-full-java17-openj9-ubi
24.0.0.3-full-java11-openj9-ubi
24.0.0.3-full-java8-openj9-ubi
24.0.0.3-full-java8-ibmjava-ubi
```

## 23.0.0.12

```
23.0.0.12-kernel-slim-java17-openj9-ubi
23.0.0.12-kernel-slim-java11-openj9-ubi
23.0.0.12-kernel-slim-java8-openj9-ubi
23.0.0.12-kernel-slim-java8-ibmjava-ubi

23.0.0.12-full-java17-openj9-ubi
23.0.0.12-full-java11-openj9-ubi
23.0.0.12-full-java8-openj9-ubi
23.0.0.12-full-java8-ibmjava-ubi
```
