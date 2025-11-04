
# IBM Container Registry (ICR)

Open Liberty container images are available from the IBM Container Registry (ICR) at `icr.io/appcafe/open-liberty`. Our recommendation is to use ICR instead of Docker Hub since ICR doesn't impose rate limits on image pulls. Images can be pulled from ICR without authentication. Only images with Universal Base Image (UBI) as the Operating System are available in ICR.

The images for the latest Liberty release and the last two quarterly releases (versions ending in _.3_, _.6_, _.9_ and _.12_) are available and are refreshed regularly (every 1-2 weeks) to include fixes for the operating system (OS) and Java.

Available image tags are listed below. The tags use the following naming convention. For more information on tags, see [Container image tags naming conventions](https://openliberty.io/docs/latest/container-images.html#tags) documentation.
```
<optional fix pack version-><liberty image type>-<java version>-<java type>-<base image type>
```

Liberty images based on Universal Base Image (UBI) 9 Minimal end with `-ubi-minimal` and include the JRE of IBM Semeru Runtime 25, 21, 17, 11 or 8 or IBM Java 8. We recommend using this combination as it offers a compact and effective Java runtime. Liberty images with Java 21 and higher are only available on UBI Minimal.

Liberty images based on UBI 8 Standard end with `-ubi` and include Java 17, 11 or 8. The `openj9` type includes IBM Semeru Runtime for the respective Java version with the JDK. Java 8 images with the `ibmjava` type and based on UBI 8 standard include IBM Java 8 JRE.

The `latest` tag simplifies pulling the full latest Open Liberty release with the latest Java JRE. It is an alias for the `full-java25-openj9-ubi-minimal` tag. If you do not specify a tag value, `latest` is used by default.

The `beta` tag is based on UBI 9 minimal and the latest Java JRE and provides the most recent beta release of Liberty, which includes all the features and capabilities from the most recent release, plus new and updated features that are currently in development.

Append a tag to `icr.io/appcafe/open-liberty` to pull a specific image. For example: 
```
icr.io/appcafe/open-liberty:25.0.0.9-kernel-slim-java17-openj9-ubi
```

Available images can be listed using [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-getting-started). Log in with your IBMid prior to running the following commands. Note that authentication is only required to list the images. **Images can be pulled from ICR without authentication**: 
```
ibmcloud cr region-set global 
ibmcloud cr images --restrict appcafe/open-liberty
```

## Latest version

The following tags include the most recent Open Liberty version: `25.0.0.11`

```
kernel-slim-java25-openj9-ubi-minimal
kernel-slim-java21-openj9-ubi-minimal
kernel-slim-java17-openj9-ubi-minimal
kernel-slim-java11-openj9-ubi-minimal
kernel-slim-java8-openj9-ubi-minimal
kernel-slim-java8-ibmjava-ubi-minimal

kernel-slim-java17-openj9-ubi
kernel-slim-java11-openj9-ubi
kernel-slim-java8-openj9-ubi
kernel-slim-java8-ibmjava-ubi

full-java25-openj9-ubi-minimal
full-java21-openj9-ubi-minimal
full-java17-openj9-ubi-minimal
full-java11-openj9-ubi-minimal
full-java8-openj9-ubi-minimal
full-java8-ibmjava-ubi-minimal

full-java17-openj9-ubi
full-java11-openj9-ubi
full-java8-openj9-ubi
full-java8-ibmjava-ubi

latest
```

## Beta

The `beta` tag includes all the features and capabilities from the most recent release, plus new and updated features currently being developed for the next release.

```
beta
```

## 25.0.0.11

```
25.0.0.11-kernel-slim-java25-openj9-ubi-minimal
25.0.0.11-kernel-slim-java21-openj9-ubi-minimal
25.0.0.11-kernel-slim-java17-openj9-ubi-minimal
25.0.0.11-kernel-slim-java11-openj9-ubi-minimal
25.0.0.11-kernel-slim-java8-openj9-ubi-minimal
25.0.0.11-kernel-slim-java8-ibmjava-ubi-minimal

25.0.0.11-kernel-slim-java17-openj9-ubi
25.0.0.11-kernel-slim-java11-openj9-ubi
25.0.0.11-kernel-slim-java8-openj9-ubi
25.0.0.11-kernel-slim-java8-ibmjava-ubi

25.0.0.11-full-java25-openj9-ubi-minimal
25.0.0.11-full-java21-openj9-ubi-minimal
25.0.0.11-full-java17-openj9-ubi-minimal
25.0.0.11-full-java11-openj9-ubi-minimal
25.0.0.11-full-java8-openj9-ubi-minimal
25.0.0.11-full-java8-ibmjava-ubi-minimal

25.0.0.11-full-java17-openj9-ubi
25.0.0.11-full-java11-openj9-ubi
25.0.0.11-full-java8-openj9-ubi
25.0.0.11-full-java8-ibmjava-ubi
```

## 25.0.0.9

```
25.0.0.9-kernel-slim-java21-openj9-ubi-minimal
25.0.0.9-kernel-slim-java17-openj9-ubi-minimal
25.0.0.9-kernel-slim-java11-openj9-ubi-minimal
25.0.0.9-kernel-slim-java8-openj9-ubi-minimal
25.0.0.9-kernel-slim-java8-ibmjava-ubi-minimal

25.0.0.9-kernel-slim-java17-openj9-ubi
25.0.0.9-kernel-slim-java11-openj9-ubi
25.0.0.9-kernel-slim-java8-openj9-ubi
25.0.0.9-kernel-slim-java8-ibmjava-ubi

25.0.0.9-full-java21-openj9-ubi-minimal
25.0.0.9-full-java17-openj9-ubi-minimal
25.0.0.9-full-java11-openj9-ubi-minimal
25.0.0.9-full-java8-openj9-ubi-minimal
25.0.0.9-full-java8-ibmjava-ubi-minimal

25.0.0.9-full-java17-openj9-ubi
25.0.0.9-full-java11-openj9-ubi
25.0.0.9-full-java8-openj9-ubi
25.0.0.9-full-java8-ibmjava-ubi
```

## 25.0.0.6

```
25.0.0.6-kernel-slim-java21-openj9-ubi-minimal
25.0.0.6-kernel-slim-java17-openj9-ubi-minimal
25.0.0.6-kernel-slim-java11-openj9-ubi-minimal
25.0.0.6-kernel-slim-java8-openj9-ubi-minimal
25.0.0.6-kernel-slim-java8-ibmjava-ubi-minimal

25.0.0.6-kernel-slim-java17-openj9-ubi
25.0.0.6-kernel-slim-java11-openj9-ubi
25.0.0.6-kernel-slim-java8-openj9-ubi
25.0.0.6-kernel-slim-java8-ibmjava-ubi

25.0.0.6-full-java21-openj9-ubi-minimal
25.0.0.6-full-java17-openj9-ubi-minimal
25.0.0.6-full-java11-openj9-ubi-minimal
25.0.0.6-full-java8-openj9-ubi-minimal
25.0.0.6-full-java8-ibmjava-ubi-minimal

25.0.0.6-full-java17-openj9-ubi
25.0.0.6-full-java11-openj9-ubi
25.0.0.6-full-java8-openj9-ubi
25.0.0.6-full-java8-ibmjava-ubi
```

## 25.0.0.3

```
25.0.0.3-kernel-slim-java21-openj9-ubi-minimal
25.0.0.3-kernel-slim-java17-openj9-ubi
25.0.0.3-kernel-slim-java11-openj9-ubi
25.0.0.3-kernel-slim-java8-openj9-ubi
25.0.0.3-kernel-slim-java8-ibmjava-ubi

25.0.0.3-full-java21-openj9-ubi-minimal
25.0.0.3-full-java17-openj9-ubi
25.0.0.3-full-java11-openj9-ubi
25.0.0.3-full-java8-openj9-ubi
25.0.0.3-full-java8-ibmjava-ubi
```
