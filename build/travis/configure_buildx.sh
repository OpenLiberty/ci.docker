#!/bin/bash
#########################################################################
#
#
#                    Configure Travis for Docker Buildx
#
#
#########################################################################

function main () {
  curl -fsSL https://get.docker.com | sh
  echo "****** Enabling experimental Docker features..."
  echo '{"experimental": "enabled"}' | sudo tee /etc/docker/daemon.json

  mkdir -p $HOME/.docker
  echo '{"experimental":"enabled"}' | sudo tee $HOME/.docker/config.json

  echo "****** Starting Docker service..."
  sudo service docker start
}

main "$@"
