# ci.docker

This repository contains the Docker files for Open Liberty. There are three key directories:

* common - contains master copies of files that are shared between various tags.
* official - the Dockerfiles and related files for the official Docker images.
* community - the Dockerfiles and related files for the Docker images under the openliberty namespace.

Currently the `common` folder contains the `docker-server` and `README.md` files. When making changes to these files first make
the changes in `common` and then run `sync-master.sh` to copy these files to the directories the files need to be
in for the Docker build. All the files need to be checked into git. Docker won't allow you to copy files from
the parent directory structure, so this allows us to update once, rather than having to update in multiple locations.
