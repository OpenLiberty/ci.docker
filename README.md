# ci.docker

This repository contains the docker files for open liberty. There are three key directories:

* master - contains master copies of files that must be duplicated for multiple docker files. 
* library - the Dockerfiles and related files for the official docker images
* openliberty - the Dockerfiles and related files for the docker images under the openliberty namespace.
* bashbrew - Copies of the files docker offical images uses, but configured for local development so you don't
  need to commit changes to github.com to test them.

Currently master contains the docker-server and README.md files. When making changes to these files first make
the changes in master and then run sync-master.sh to copy these files to the directories the files need to be
in for the docker build. All the files need to be checked into git. Docker won't allow you to copy files from
the parent directory structure, so this allows us to update once, rather than having to update in multiple 
locations.
