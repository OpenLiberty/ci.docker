#!/bin/bash

readonly usage="Usage: $0 -n <project/namespace>"

main() {
    parse_args "$@"
    check_args

    export OCP_USER=kubeadmin
    oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
    export OCP_DOCKER_HOST=$(oc get route default-route --namespace openshift-image-registry \
    --template='{{ .spec.host }}')
    oc create serviceaccount $OCP_USER
    oc policy add-role-to-user edit system:serviceaccount:$OCP_PROJECT:$OCP_USER

    echo | openssl s_client -connect $OCP_DOCKER_HOST:443 -showcerts | sed -n "/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p" > ca.crt

    mkdir -p /etc/docker/certs.d/$OCP_DOCKER_HOST
    cp ca.crt /etc/docker/certs.d/$OCP_DOCKER_HOST
    systemctl restart docker.service

    export OCP_DOCKER_HOST=$(oc get route default-route --namespace openshift-image-registry \
    --template='{{ .spec.host }}')

    docker login -u unused -p $(oc whoami -t)  $OCP_DOCKER_HOST

    oc create configmap registry-cas -n openshift-config --from-file=$OCP_DOCKER_HOST=/etc/docker/certs.d/$OCP_DOCKER_HOST/ca.crt
    oc patch image.config.openshift.io/cluster --patch '{"spec":{"additionalTrustedCA":
    {"name":"registry-cas"}}}' --type=merge

    oc create secret generic regcred --from-file=.dockerconfigjson="${HOME}/.docker/config.json" --type=kubernetes.io/dockerconfigjson

    oc create sa privilegedsa
    oc adm policy add-scc-to-user privileged -z privilegedsa

    IMAGE_TAG=26.0.0.3-kernel-slim-java11-openj9-ubi-minimal-0.0.1
    IMAGE_NAME="open-liberty"
    IMAGE=$OCP_DOCKER_HOST/$OCP_PROJECT/$IMAGE_NAME:$IMAGE_TAG
    docker build -t $IMAGE -f Dockerfile.ubi9-minimal.openjdk11 .
    docker push $IMAGE
}

check_args() {
    if [[ -z "${OCP_PROJECT}" ]]; then
        echo "****** Missing OCP project, see usage"
        echo "${usage}"
        exit 1
    fi
}

parse_args() {
    while [ $# -gt 0 ]; do
    case "$1" in
    -n)
      shift
      readonly OCP_PROJECT="${1}"
      ;;
    *)
      echo "Error: Invalid argument - $1"
      echo "$usage"
      exit 1
      ;;
    esac
    shift
  done
}

main "$@"

