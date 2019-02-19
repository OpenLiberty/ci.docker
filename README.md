# Docker Hub images

There are three different Open Liberty Docker image sets available on Docker Hub:

1. **Official Images**:  available [here](https://hub.docker.com/_/open-liberty), these are re-build automatically anytime something changes in the layers below, and updated with new Open Liberty binaries as they become available (generally every 4 weeks).  The Dockerfiles can be found in the [official](/official) directory.  

1. **Daily Images**: available [here](https://hub.docker.com/r/openliberty/daily), these are daily images from the daily Open Liberty binaries.  The scripts used for this image can be found [here](https://github.com/OpenLiberty/ci.docker.daily).

1. **Community Images**: available [here](https://hub.docker.com/r/openliberty/open-liberty), these are images using OpenJ9 in the JVM.  The Dockerfiles can be found in the [community](/community) directory.

## Building an application image 

According to Docker's best practices you should create a new image (`FROM open-liberty`) which adds a single application and the corresponding configuration. You should avoid configuring the image manually, after it started (unless it is for debugging purposes), because such changes won't be present if you spawn a new container from the image.

Even if you Docker save the manually configured container, the steps to reproduce the image from `open-liberty` will be lost and you will hinder your ability to update that image.

The key point to take-away from the sections below is that your application Dockerfile should always follow a pattern similar to:

```dockerfile
FROM open-liberty

# Add my app and config
COPY Sample1.war /config/dropins/
COPY server.xml /config/
```

This will result in a Docker image that has your application and configuration pre-loaded, which means you can spawn new fully-configured containers at any time.

## Updating common files

Currently the `common` folder contains the `docker-server` and `README.md` files. When making changes to these files first make
the changes in `common` and then run `sync-master.sh` to copy these files to the directories the files need to be
in for the Docker build. All the files need to be checked into git. Docker won't allow you to copy files from
the parent directory structure, so this allows us to update once, rather than having to update in multiple locations.


