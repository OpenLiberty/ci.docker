#! /bin/bash
#####################################################################################
#                                                                                   #
#  Script to verify an Open Liberty image certificates                              #
#                                                                                   #
#                                                                                   #
#  Usage : verifyLibertyCertificates.sh <Image name>                                # 
#                                                                                   #
#####################################################################################

image=$1
tag=`echo $image | cut -d ":" -f2`
cname="${tag}test"
DOCKER=docker

serverCleanup()
{
    cid=$1
    $DOCKER logs $cid
    $DOCKER stop $cid >/dev/null
    $DOCKER rm -f $cid >/dev/null
}

checkCommandForSuccess()
{
    cid=$1
    command=$2
    failMessage=$3
    $DOCKER exec -it $cid sh -c "$command"
    if [ $? != 0 ]
    then
        echo "$failMessage"
        serverCleanup $cid
        exit 1
    fi
}

testLibertyCertificates()
{
    cid=$($DOCKER run -d $image)
    # Wait until the server starts to know that the certs have been loaded 
    maxRetry=10
    i=0
    serverLaunched=false
    while [ $serverLaunched = false ] && [ $i -lt $maxRetry ]; do
        sleep 1
        echo "Checking logs ($(( $i + 1 ))/$maxRetry)"
        launchMessage=$($DOCKER logs $cid | grep "Launching defaultServer" -c)
        if [ $launchMessage -eq 1 ]; then
            echo "Launch message found!"
            serverLaunched=true
        fi
        i=$(( $i + 1 ))
    done
    if [ $serverLaunched = false ]; then
        echo "Server failed to start"
        serverCleanup $cid
        exit 1
    fi

    # Validate that openssl package is present in the Liberty image
    checkCommandForSuccess $cid "which openssl" "Server failed to generate keystore"

    # Validate that the certificate is added to the Liberty default keystore
    checkCommandForSuccess $cid "ls /output/resources/security/key.p12" "Server failed to add certificate to keystore"

    # Validate that the certificate is added to the Liberty default truststore
    checkCommandForSuccess $cid "ls /output/resources/security/trust.p12" "Server failed to add certificate to truststore"

    serverCleanup $cid >/dev/null
}

tests=$(declare -F | cut -d" " -f3 | grep "test")
for name in $tests
do
   timestamp=$(date '+%Y/%m/%d %H:%M:%S')
   echo "$timestamp *** $name - Executing"
   eval $name
   timestamp=$(date '+%Y/%m/%d %H:%M:%S')
   echo "$timestamp *** $name - Completed successfully"
done